# Flatpak configuration with nix-flatpak for declarative package management
{ inputs, ... }:

{
  flake.modules.nixos.flatpak =
    { pkgs, lib, ... }:
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

      # Fix for NixOS-specific Flatpak issues
      # Create /bin directory and /bin/sh symlink required by Flatpak's bwrap
      # Using a simple activation script that runs after other binsh setup
      system.activationScripts.flatpak-binsh = lib.mkAfter ''
        mkdir -p /bin
        ln -sfn ${pkgs.bash}/bin/sh /bin/sh
      '';

      # Add Flatpak export directories to XDG_DATA_DIRS
      environment.sessionVariables.XDG_DATA_DIRS = lib.mkAfter [
        "/var/lib/flatpak/exports/share"
        "$HOME/.local/share/flatpak/exports/share"
      ];

      # Ensure XDG portal is enabled for Flatpak integration
      xdg.portal.enable = true;
    };
}
