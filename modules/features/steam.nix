# Steam - Valve's gaming platform
{ inputs, ... }:

{
  flake.modules.nixos.steam =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.features.steam;
    in
    {
      options.features.steam.enable = lib.mkEnableOption "Steam gaming platform";

      # steam-config-nix must be imported at module top-level (not inside config/mkIf)
      imports = [ inputs.steam-config-nix.nixosModules.default ];

      config = lib.mkIf cfg.enable {
        programs.steam = {
          enable = true;
          remotePlay.openFirewall = true;
          dedicatedServer.openFirewall = true;
          extraCompatPackages = [ pkgs.proton-ge-bin ];

          # Per-game settings that used to be typed into Steam's GUI. Steam owns
          # the compat tool mapping, so changing it waits for Steam to close;
          # everything else compiles into a wrapper script and applies at once.
          #
          # Not covered here: the "run the Windows version" platform overrides on
          # Rocket League, AC Origins, VTube Studio, VBridger, Hogwarts Legacy and
          # Tape to Tape. steam-config-nix cannot write those, so they stay set
          # inside Steam itself.
          config = {
            enable = true;

            apps = {
              # Was pinned to GE-Proton by hand in Steam
              "252950" = {
                name = "Rocket League";
                compatTool = pkgs.proton-ge-bin;
              };
            }
            # Capture the Vulkan output in OBS instead of a window grab. Only
            # worth wrapping when OBS is actually installed, since the capture
            # tool ships as one of its plugins.
            // lib.optionalAttrs (config.features."obs-studio".enable or false) {
              "1325860" = {
                name = "VTube Studio";
                wrappers = [ "${pkgs.obs-studio-plugins.obs-vkcapture}/bin/obs-vkcapture" ];
              };
            };
          };
        };

        # Steam dependencies - 32-bit graphics required for most games
        # mkDefault allows gpu.nix to override if needed
        hardware.graphics.enable = lib.mkDefault true;
        hardware.graphics.enable32Bit = lib.mkDefault true;
      };
    };
}
