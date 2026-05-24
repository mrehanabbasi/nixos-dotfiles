# VoxType push-to-talk voice-to-texk application
{ inputs, ... }:

{
  flake.modules.homeManager.voxtype =
    { config, lib, pkgs, ... }:
    let
      cfg = config.features.voxtype;
    in
    {
      options.features.voxtype.enable = lib.mkEnableOption "VoxType push-to-talk voice-to-text";
      config = lib.mkIf cfg.enable {
        programs.voxtype = {
          enable = true;
          engine = "whisper";
          package = inputs.voxtype.packages.${pkgs.stdenv.hostPlatform.system}.vulkan;
          model.name = "base.en";
          service.enable = true;
          settings = {
            # Using Hyprland keybinding instead
            # hotkey = {
            #   enabled = true;
            #   key = "INSERT";
            # };
            whisper.language = "en";
            output = {
              mode = "type";
              fallback_to_clipboard = true;
            };
            text = {
              spoken_punctuation = true;
              replacements = {
                "vox type" = "voxtype";
              };
            };
            state_file = "auto";
          };
        };
      };
    };
}
