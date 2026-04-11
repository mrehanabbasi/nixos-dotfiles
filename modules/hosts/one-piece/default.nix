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
      inputs.self.modules.nixos.dms-greeter
      inputs.self.modules.nixos.brave
      inputs.self.modules.nixos.thunar
      inputs.self.modules.nixos.obs-studio
      inputs.self.modules.nixos.localsend
      inputs.self.modules.nixos.appimage
      inputs.self.modules.nixos.core-packages
      inputs.self.modules.nixos.core-services
      inputs.self.modules.nixos.zsh
      inputs.self.modules.nixos.neovim
      inputs.self.modules.nixos.ghostty
      inputs.self.modules.nixos.gpg
      inputs.self.modules.nixos.kdeconnect

      # ════════════════════════════════════════════════════════════════════
      # LAYER 7: Optional features
      # ════════════════════════════════════════════════════════════════════
      inputs.self.modules.nixos.steam
      inputs.self.modules.nixos.gamemode
      inputs.self.modules.nixos.wine

      # ════════════════════════════════════════════════════════════════════
      # LAYER 8: Host-specific hardware
      # ════════════════════════════════════════════════════════════════════
      inputs.self.modules.nixos.one-piece-hardware
      inputs.self.modules.nixos.one-piece-gpu
      inputs.self.modules.nixos.one-piece-network
      inputs.self.modules.nixos.one-piece-bluetooth
      inputs.self.modules.nixos.one-piece-kanata

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
