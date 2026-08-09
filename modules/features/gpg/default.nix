# GPG configuration with public key
_:

{
  flake.modules.nixos.gpg =
    { config, lib, ... }:
    let
      cfg = config.features.gpg;
    in
    {
      options.features.gpg.enable = lib.mkEnableOption "GPG key management";
    };

  flake.modules.homeManager.gpg =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.features.gpg;
    in
    {
      options.features.gpg.enable = lib.mkEnableOption "GPG key management";

      config = lib.mkIf cfg.enable {
        programs.gpg = {
          enable = true;
          publicKeys = [
            {
              source = ./public-key.asc;
              trust = "ultimate";
            }
          ];
        };

        services.gpg-agent = {
          enable = true;
          enableSshSupport = true;
          enableZshIntegration = true;
          pinentry.package = pkgs.pinentry-qt;
        };

        # Release stale keyboxd database locks on login. keyboxd runs
        # on-demand (no socket activation), so an unclean exit (suspend,
        # session end, kill) orphans the pubring.db dotlock and its .#lk
        # temp files. gnupg only breaks the stale lock after a 10s timeout,
        # surfacing as "keydb_search failed: Connection timed out" on the
        # next GPG op (e.g. commit signing). See dev.gnupg.org/T6838.
        systemd.user.services.keyboxd-unlock = {
          Unit = {
            Description = "Release stale GnuPG keyboxd database locks";
            Documentation = "https://dev.gnupg.org/T6838";
          };
          Service = {
            Type = "oneshot";
            ExecStart = pkgs.writeShellScript "keyboxd-unlock" ''
              set -eu
              pkdir="${config.programs.gpg.homedir}/public-keys.d"
              # Break a stale pubring.db lock (no-op if held by a live process).
              "${config.programs.gpg.package}/bin/gpgconf" --unlock pubring.db || true
              # Prune orphaned dotlock temp files (link count 1 == not the
              # active lock) whose owning PID is dead. The active lock has
              # link count 2 and is never touched.
              if [ -d "$pkdir" ]; then
                for f in "$pkdir"/.#lk0x*; do
                  [ -e "$f" ] || continue
                  links=$(${pkgs.coreutils}/bin/stat -c '%h' "$f")
                  [ "$links" -eq 1 ] || continue
                  pid=$(${pkgs.coreutils}/bin/head -n1 "$f" | ${pkgs.coreutils}/bin/tr -d ' ')
                  if [ -n "$pid" ] && ! kill -0 "$pid" 2>/dev/null; then
                    rm -f "$f"
                  fi
                done
              fi
            '';
          };
          Install.WantedBy = [ "default.target" ];
        };
      };
    };
}
