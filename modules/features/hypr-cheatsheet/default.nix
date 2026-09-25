# Hyprland shortcut cheatsheet overlay (Quickshell)
#
# Runs as a small always-resident Quickshell instance so the overlay appears
# instantly; `hypr-cheatsheet` just pokes it over Quickshell's IPC socket.
# Bound to SUPER+? in modules/features/hyprland/hyprland.lua.
_:

{
  flake.modules.homeManager.hypr-cheatsheet =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.features.hypr-cheatsheet;

      configName = "hypr-cheatsheet";

      # Toggle entry point. Kept as a wrapper rather than inlining the qs
      # invocation into the keybind so the Lua config stays free of store paths.
      toggleScript = pkgs.writeShellScriptBin "hypr-cheatsheet" ''
        exec ${lib.getExe pkgs.quickshell} -c ${configName} ipc call cheatsheet "''${1:-toggle}"
      '';
    in
    {
      options.features.hypr-cheatsheet.enable = lib.mkEnableOption "Hyprland shortcut cheatsheet overlay";

      config = lib.mkIf cfg.enable {
        # Quickshell discovers configs as <xdg config>/quickshell/<name>/shell.qml
        xdg.configFile."quickshell/${configName}/shell.qml".source = ./shell.qml;

        home.packages = [
          toggleScript
          pkgs.quickshell
        ];

        systemd.user.services.hypr-cheatsheet = {
          Unit = {
            Description = "Hyprland shortcut cheatsheet overlay";
            PartOf = [ "graphical-session.target" ];
            After = [ "graphical-session.target" ];
            # The overlay is a convenience, not part of the session - never let a
            # crash loop here take down or block anything else.
            X-Restart-Triggers = [ "${./shell.qml}" ];
          };

          Service = {
            ExecStart = "${lib.getExe pkgs.quickshell} -c ${configName} --no-duplicate";
            Restart = "on-failure";
            RestartSec = 3;
            Slice = "session.slice";
          };

          Install.WantedBy = [ "graphical-session.target" ];
        };
      };
    };
}
