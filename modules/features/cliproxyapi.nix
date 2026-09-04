# CLIProxyAPI - wraps Claude Code/Codex/Gemini/Antigravity CLI logins as an
# OpenAI/Gemini/Claude/Codex-compatible API proxy (github.com/router-for-me/CLIProxyAPI)
# Runs as a rootless podman container under a user systemd service, so
# `podman ps` / `systemctl --user status cliproxyapi` work without sudo.
_:

{
  flake.modules.homeManager.cliproxyapi =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.features.cliproxyapi;
      stateDir = "${config.xdg.dataHome}/cliproxyapi";
      defaultConfig = pkgs.writeText "cliproxyapi-config.yaml" ''
        host: ""
        port: ${toString cfg.port}
        auth-dir: "/root/.cli-proxy-api"
        debug: false
      '';
    in
    {
      options.features.cliproxyapi = {
        enable = lib.mkEnableOption "CLIProxyAPI proxy server (rootless podman)";
        port = lib.mkOption {
          type = lib.types.port;
          default = 8317;
          description = "Port CLIProxyAPI listens on (bound to localhost only).";
        };
      };

      config = lib.mkIf cfg.enable {
        home.activation.cliproxyapiState = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          run mkdir -p ${lib.escapeShellArg stateDir}/auth ${lib.escapeShellArg stateDir}/plugins
          if [[ ! -e ${lib.escapeShellArg stateDir}/config.yaml ]]; then
            run install -m 0640 ${defaultConfig} ${lib.escapeShellArg stateDir}/config.yaml
          fi
        '';

        systemd.user.services.cliproxyapi = {
          Unit = {
            Description = "CLIProxyAPI proxy server";
            After = [ "network-online.target" ];
          };
          Service = {
            Type = "simple";
            ExecStartPre = "-${pkgs.podman}/bin/podman rm -f cliproxyapi";
            ExecStart = ''
              ${pkgs.podman}/bin/podman run --rm --name cliproxyapi \
                -p 127.0.0.1:${toString cfg.port}:8317 \
                -v ${stateDir}/config.yaml:/CLIProxyAPI/config.yaml \
                -v ${stateDir}/auth:/root/.cli-proxy-api \
                -v ${stateDir}/plugins:/CLIProxyAPI/plugins \
                docker.io/eceasy/cli-proxy-api:latest
            '';
            ExecStop = "${pkgs.podman}/bin/podman stop -t 10 cliproxyapi";
            Restart = "on-failure";
            RestartSec = 5;
          };
          Install.WantedBy = [ "default.target" ];
        };
      };
    };
}
