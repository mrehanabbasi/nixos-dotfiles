# Flatpak configuration with nix-flatpak for declarative package management
{ inputs, ... }:

{
  flake.modules.nixos.flatpak =
    { config, lib, ... }:
    let
      cfg = config.features.flatpak;
    in
    {
      options.features.flatpak.enable = lib.mkEnableOption "Flatpak with declarative package management";

      # nix-flatpak module must be imported at module top-level (not inside config/mkIf)
      imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];

      config = lib.mkIf cfg.enable {
        # Flatpak service configuration
        services.flatpak = {
          enable = true;

          # Declarative Flatpak packages
          packages = [
            # Facetracker - Face tracking application
            "de.z_ray.Facetracker"
          ];

          # Enable automatic updates for Flatpak applications
          update.auto = {
            enable = true;
            onCalendar = "daily"; # Run updates daily
          };
        };

        # Add Flatpak export directories to XDG_DATA_DIRS
        environment.sessionVariables.XDG_DATA_DIRS = lib.mkAfter [
          "/var/lib/flatpak/exports/share"
          "$HOME/.local/share/flatpak/exports/share"
        ];

        # Ensure XDG portal is enabled for Flatpak integration
        xdg.portal.enable = true;
      };
    };
}
