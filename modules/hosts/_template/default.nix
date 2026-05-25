# Template for new hosts
# Copy this directory and customize for your new machine
#
# Steps:
# 1. Copy this directory: cp -r _template new-hostname
# 2. Generate hardware config: nixos-generate-config --show-hardware-config > hardware.nix
# 3. Register hardware.nix as a flake module: add flake.modules.nixos.new-hostname-hardware = _: { imports = [ ./hardware.nix ]; }; in a nix file in this dir, then reference it as inputs.self.modules.nixos.new-hostname-hardware
# 4. Create gpu.nix, network.nix, etc. as needed following the same pattern
# 5. Update the host definition below
# 6. Remove the underscore prefix from the directory name
#
{ inputs, ... }:
let
  helpers = import ../../_lib { inherit inputs; };
in
{
  flake.nixosConfigurations.new-hostname = helpers.mkNixos {
    system = "x86_64-linux";
    modules = [
      # External flake modules
      inputs.catppuccin.nixosModules.catppuccin
      inputs.sops-nix.nixosModules.sops
      inputs.home-manager.nixosModules.home-manager

      # Base system
      inputs.self.modules.nixos.base
      inputs.self.modules.nixos.boot
      inputs.self.modules.nixos.networking
      inputs.self.modules.nixos.virtualisation
      inputs.self.modules.nixos.fonts

      # Secrets
      inputs.self.modules.nixos.sops

      # Theming
      inputs.self.modules.nixos.catppuccin

      # Services
      inputs.self.modules.nixos.audio
      inputs.self.modules.nixos.tailscale

      # Desktop
      inputs.self.modules.nixos.hyprland
      inputs.self.modules.nixos."dms-greeter"
      inputs.self.modules.nixos.brave
      inputs.self.modules.nixos."core-packages"
      inputs.self.modules.nixos."core-services"
      inputs.self.modules.nixos.zsh
      inputs.self.modules.nixos.neovim
      inputs.self.modules.nixos.ghostty
      inputs.self.modules.nixos.gpg
      inputs.self.modules.nixos.kdeconnect

      # Host-specific (add these as modules in this directory)
      # inputs.self.modules.nixos.new-hostname-hardware
      # inputs.self.modules.nixos.new-hostname-gpu
      # inputs.self.modules.nixos.new-hostname-network

      # User
      inputs.self.modules.nixos.rehan

      # Host-specific overrides and feature enables
      {
        networking.hostName = "new-hostname";
        time.timeZone = "Asia/Karachi";
        system.stateVersion = "25.11";

        # Enable features (add/remove as needed for this host)
        features.base.enable = true;
        features.boot.enable = true;
        features.fonts.enable = true;
        features.networking.enable = true;
        features.virtualisation.enable = true;
        features.sops.enable = true;
        features.catppuccin.enable = true;
        features.audio.enable = true;
        features.tailscale.enable = true;
        features.hyprland.enable = true;
        features."dms-greeter".enable = true;
        features.brave.enable = true;
        features."core-packages".enable = true;
        features."core-services".enable = true;
        features.zsh.enable = true;
        features.neovim.enable = true;
        features.kdeconnect.enable = true;
      }
    ];
  };
}
