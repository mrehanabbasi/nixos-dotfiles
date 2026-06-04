# Sesh - smart tmux session manager
_:

{
  flake.modules.homeManager.sesh =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.features.sesh;
      repoPath = "${config.home.homeDirectory}/nixos-dotfiles";
      repoUrl = "https://github.com/mrehanabbasi/nixos-dotfiles";
      launcher = pkgs.writeShellScriptBin "nixos-session" ''
        set -e
        if [ ! -d "${repoPath}" ]; then
          ${pkgs.git}/bin/git clone ${repoUrl} "${repoPath}"
        fi
        exec ${pkgs.sesh}/bin/sesh connect nixos
      '';
    in
    {
      options.features.sesh.enable = lib.mkEnableOption "sesh tmux session manager";

      config = lib.mkIf cfg.enable {
        home.packages = [
          pkgs.sesh
          launcher
        ];

        xdg.configFile."sesh/sesh.toml".text = ''
          [[session]]
          name = "nixos"
          path = "${repoPath}"
          startup_command = "nvim ."
          windows = ["term", "term"]
        '';
      };
    };
}
