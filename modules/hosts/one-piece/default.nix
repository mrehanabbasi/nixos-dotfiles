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
      inputs.self.modules.nixos.host
      inputs.self.modules.nixos.base
      inputs.self.modules.nixos.boot
      inputs.self.modules.nixos.networking
      inputs.self.modules.nixos.virtualisation
      inputs.self.modules.nixos.fonts

      # ════════════════════════════════════════════════════════════════════
      # LAYER 3: Secrets (before services that use them)
      # ════════════════════════════════════════════════════════════════════
      inputs.self.modules.nixos.sops
      inputs.self.modules.nixos.context7

      # ════════════════════════════════════════════════════════════════════
      # LAYER 4: Theming (before modules that use theme options)
      # ════════════════════════════════════════════════════════════════════
      inputs.self.modules.nixos.catppuccin

      # ════════════════════════════════════════════════════════════════════
      # LAYER 5: Services (may depend on secrets/theming)
      # ════════════════════════════════════════════════════════════════════
      inputs.self.modules.nixos.audio
      inputs.self.modules.nixos."vm-audio"
      inputs.self.modules.nixos.tailscale
      inputs.self.modules.nixos.pia
      inputs.self.modules.nixos.flatpak

      # ════════════════════════════════════════════════════════════════════
      # LAYER 6: Desktop & Programs
      # ════════════════════════════════════════════════════════════════════
      inputs.self.modules.nixos.hyprland
      inputs.self.modules.nixos."dms-greeter"
      inputs.self.modules.nixos.brave
      inputs.self.modules.nixos.thunar
      inputs.self.modules.nixos."obs-studio"
      inputs.self.modules.nixos.localsend
      inputs.self.modules.nixos.appimage
      inputs.self.modules.nixos."core-packages"
      inputs.self.modules.nixos."core-services"
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
      inputs.self.modules.nixos."davinci-resolve"
      inputs.self.modules.nixos.ollama
      inputs.self.modules.nixos.kanata
      inputs.self.modules.nixos."vtube-studio"

      # ════════════════════════════════════════════════════════════════════
      # LAYER 8: Host-specific hardware
      # ════════════════════════════════════════════════════════════════════
      inputs.self.modules.nixos.one-piece-hardware
      inputs.self.modules.nixos.one-piece-gpu
      inputs.self.modules.nixos.one-piece-display
      inputs.self.modules.nixos.one-piece-network
      inputs.self.modules.nixos.one-piece-bluetooth
      inputs.self.modules.nixos.one-piece-input

      # ════════════════════════════════════════════════════════════════════
      # LAYER 9: User (composes Home Manager)
      # ════════════════════════════════════════════════════════════════════
      inputs.self.modules.nixos.rehan

      # ════════════════════════════════════════════════════════════════════
      # Host-specific overrides
      # ════════════════════════════════════════════════════════════════════
      {
        time.timeZone = "Asia/Karachi";
        system.stateVersion = "26.05";
        features = {
          sops.enable = true;
          context7.enable = true;
          catppuccin.enable = true;
          base.enable = true;
          boot.enable = true;
          fonts.enable = true;
          networking.enable = true;
          virtualisation.enable = true;
          audio = {
            enable = true;
            # Guest VMs reach the host's PipeWire over TCP; the interface it is
            # exposed on comes from host.vmBridge.
            pulseNetwork.enable = true;
          };
          appimage.enable = true;
          brave.enable = true;
          "core-packages".enable = true;
          "core-services".enable = true;
          flatpak.enable = true;
          gamemode.enable = true;
          ghostty.enable = true;
          localsend.enable = true;
          "obs-studio".enable = true;
          pia.enable = true;
          steam.enable = true;
          tailscale.enable = true;
          thunar.enable = true;
          "vm-audio".enable = true;
          wine.enable = true;
          "davinci-resolve".enable = true;
          ollama.enable = true;
          kanata.enable = true;
          "vtube-studio".enable = true;
          zsh.enable = true;
          neovim.enable = true;
          hyprland.enable = true;
          kdeconnect.enable = true;
          gpg.enable = true;
          "dms-greeter".enable = true;
        };
      }
    ];
  };
}
