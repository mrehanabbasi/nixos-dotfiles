# Template for new hosts
# Copy this directory and customize for your new machine
#
# Steps:
# 1. Copy this directory: cp -r _template new-hostname
# 2. Generate hardware config: nixos-generate-config --show-hardware-config > hardware.nix
# 3. Create gpu.nix, network.nix, etc. as needed
# 4. Update the host definition below
# 5. Remove the underscore prefix from the directory name
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

      # Secrets
      inputs.self.modules.nixos.sops

      # Theming
      inputs.self.modules.nixos.catppuccin

      # Services
      inputs.self.modules.nixos.audio
      inputs.self.modules.nixos.tailscale

      # Desktop
      inputs.self.modules.nixos.hyprland
      inputs.self.modules.nixos.sddm
      inputs.self.modules.nixos.browsers
      inputs.self.modules.nixos.system-packages
      inputs.self.modules.nixos.zsh
      inputs.self.modules.nixos.neovim
      inputs.self.modules.nixos.ghostty
      inputs.self.modules.nixos.gpg
      inputs.self.modules.nixos.kdeconnect

      # Host-specific (customize these)
      ./hardware.nix
      # ./gpu.nix
      # ./network.nix
      # ./bluetooth.nix

      # User
      inputs.self.modules.nixos.rehan

      # Host-specific overrides
      {
        networking.hostName = "new-hostname";
        time.timeZone = "Asia/Karachi";
        system.stateVersion = "25.11";
      }
    ];
  };
}
