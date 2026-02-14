# Host definition for one-piece
# Composes shared aspects with host-specific hardware configuration
{ inputs, ... }:
let
  helpers = import ../../_lib { inherit inputs; };
in
{
  flake.nixosConfigurations.one-piece = helpers.mkNixos {
    system = "x86_64-linux";
    modules = [
      # ════════════════════════════════════════════════════════════════════
      # LAYER 1: External flake modules (define options first)
      # ════════════════════════════════════════════════════════════════════
      inputs.catppuccin.nixosModules.catppuccin
      inputs.pia.nixosModules.default
      inputs.sops-nix.nixosModules.sops
      inputs.home-manager.nixosModules.home-manager

      # ════════════════════════════════════════════════════════════════════
      # LAYER 2: Base system (no dependencies)
      # ════════════════════════════════════════════════════════════════════
      inputs.self.modules.nixos.base
      inputs.self.modules.nixos.boot
      inputs.self.modules.nixos.networking
      inputs.self.modules.nixos.virtualisation
      inputs.self.modules.nixos.fonts

      # ════════════════════════════════════════════════════════════════════
      # LAYER 3: Secrets (before services that use them)
      # ════════════════════════════════════════════════════════════════════
      inputs.self.modules.nixos.sops

      # ════════════════════════════════════════════════════════════════════
      # LAYER 4: Theming (before modules that use theme options)
      # ════════════════════════════════════════════════════════════════════
      inputs.self.modules.nixos.catppuccin

      # ════════════════════════════════════════════════════════════════════
      # LAYER 5: Services (may depend on secrets/theming)
      # ════════════════════════════════════════════════════════════════════
      inputs.self.modules.nixos.audio
      inputs.self.modules.nixos.vm-audio
      inputs.self.modules.nixos.tailscale
      inputs.self.modules.nixos.pia
      inputs.self.modules.nixos.flatpak

      # ════════════════════════════════════════════════════════════════════
      # LAYER 6: Desktop & Programs
      # ════════════════════════════════════════════════════════════════════
      inputs.self.modules.nixos.hyprland
      inputs.self.modules.nixos.sddm
      inputs.self.modules.nixos.browsers
      inputs.self.modules.nixos.system-packages
      inputs.self.modules.nixos.zsh
      inputs.self.modules.nixos.neovim
      inputs.self.modules.nixos.ghostty
      inputs.self.modules.nixos.gpg
      inputs.self.modules.nixos.kdeconnect

      # ════════════════════════════════════════════════════════════════════
      # LAYER 7: Optional features
      # ════════════════════════════════════════════════════════════════════
      inputs.self.modules.nixos.gaming

      # ════════════════════════════════════════════════════════════════════
      # LAYER 8: Host-specific hardware (plain NixOS modules)
      # Prefixed with _ to exclude from import-tree auto-import
      # ════════════════════════════════════════════════════════════════════
      ./_hardware.nix
      ./_gpu.nix
      ./_network.nix
      ./_bluetooth.nix
      ./_kanata.nix

      # ════════════════════════════════════════════════════════════════════
      # LAYER 9: User (composes Home Manager)
      # ════════════════════════════════════════════════════════════════════
      inputs.self.modules.nixos.rehan

      # ════════════════════════════════════════════════════════════════════
      # Host-specific overrides
      # ════════════════════════════════════════════════════════════════════
      {
        time.timeZone = "Asia/Karachi";
        i18n.defaultLocale = "en_US.UTF-8";
        system.stateVersion = "25.11";
      }
    ];
  };
}
