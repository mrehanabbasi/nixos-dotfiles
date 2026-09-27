# VTube Studio - the desktop app ships through Steam (Proton), so there is no
# package to install here. What this module owns is the one thing NixOS has to
# arrange for it: the port its companion phone app connects in on.
_:

{
  flake.modules.nixos."vtube-studio" =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.features."vtube-studio";
    in
    {
      options.features."vtube-studio" = {
        enable = lib.mkEnableOption "VTube Studio phone-app connectivity";

        port = lib.mkOption {
          type = lib.types.port;
          default = 25565;
          description = ''
            Port the phone app reaches the desktop app on, over both TCP and
            UDP. Must match the port set inside VTube Studio itself.
          '';
        };

        openFirewall = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = ''
            Open {option}`port` to the local network. Turning this off leaves
            the app working but unreachable from the phone, which is the whole
            point of the feature.
          '';
        };
      };

      config = lib.mkIf (cfg.enable && cfg.openFirewall) {
        networking.firewall = {
          allowedTCPPorts = [ cfg.port ];
          allowedUDPPorts = [ cfg.port ];
        };
      };
    };
}
