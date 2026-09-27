# Template for new hosts
# Copy this directory and customize for your new machine
#
# Steps:
# 1. Copy this directory: cp -r _template new-hostname
# 2. Generate hardware config: nixos-generate-config --show-hardware-config > hardware.nix
# 3. Register hardware.nix as a flake module: add flake.modules.nixos.new-hostname-hardware = _: { imports = [ ./hardware.nix ]; }; in a nix file in this dir, then reference it as inputs.self.modules.nixos.new-hostname-hardware
# 4. Create gpu.nix, network.nix, display.nix, etc. as needed following the same pattern
# 5. Update the host definition below
# 6. Remove the underscore prefix from the directory name
#
# Feature modules stay hardware-agnostic: anything that names a GPU vendor, a
# monitor, a network interface, or assumes a battery belongs in this directory,
# fed to the feature through its options. See hosts/one-piece/display.nix and
# hosts/one-piece/vm.nix for the shape of that.
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
      inputs.self.modules.nixos.host
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
      # inputs.self.modules.nixos.new-hostname-display   # sets host.formFactor / host.displays
      # inputs.self.modules.nixos.new-hostname-network
      # inputs.self.modules.nixos.new-hostname-input     # sets host.input.internalKeyboard

      # User
      inputs.self.modules.nixos.rehan

      # Host-specific overrides and feature enables
      {
        networking.hostName = "new-hostname";
        time.timeZone = "Asia/Karachi";
        system.stateVersion = "26.05";

        # Enable features (add/remove as needed for this host)
        features = {
          base.enable = true;
          boot.enable = true;
          fonts.enable = true;
          networking.enable = true;
          virtualisation.enable = true;
          sops.enable = true;
          catppuccin.enable = true;
          audio.enable = true;
          tailscale.enable = true;
          hyprland.enable = true;
          "dms-greeter".enable = true;
          brave.enable = true;
          "core-packages".enable = true;
          "core-services".enable = true;
          zsh.enable = true;
          neovim.enable = true;
          kdeconnect.enable = true;
        };
      }
    ];
  };
}
