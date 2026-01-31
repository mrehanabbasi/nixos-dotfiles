# Flatpak configuration with nix-flatpak for declarative package management
{ inputs, ... }:

{
  flake.modules.nixos.flatpak =
    { pkgs, ... }:
    {
      # Enable nix-flatpak for declarative package management
      imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];

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
    };
}
