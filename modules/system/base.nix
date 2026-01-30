# Base system configuration - Nix settings, locale, unfree packages
{ ... }:

{
  flake.modules.nixos.base =
    { ... }:
    {
      # Allow unfree packages (needed for NVIDIA drivers, etc.)
      nixpkgs.config.allowUnfree = true;

      # Nix settings
      nix.settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        auto-optimise-store = true;
      };

      nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };

      # Internationalisation
      i18n.defaultLocale = "en_US.UTF-8";
    };
}
