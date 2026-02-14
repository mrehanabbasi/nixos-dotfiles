# User definition for rehan - NixOS user + Home Manager integration
{ inputs, ... }:
let
  userName = "rehan";
in
{
  flake.modules.nixos.${userName} =
    { pkgs, ... }:
    {
      users.users.${userName} = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "podman"
          "input"
          "uinput"
          "network"
          "networkmanager"
          "video"
          "libvirtd" # Manage VMs without sudo
          "kvm" # Access KVM device
        ];
        shell = pkgs.zsh;
        packages = with pkgs; [ tree ];
      };

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "backup";
        extraSpecialArgs = { inherit inputs; };

        users.${userName} = {
          imports = [
            inputs.catppuccin.homeModules.catppuccin

            # Theming
            inputs.self.modules.homeManager.catppuccin
            inputs.self.modules.homeManager.gtk

            # Desktop
            inputs.self.modules.homeManager.hyprland
            inputs.self.modules.homeManager.hyprlock
            inputs.self.modules.homeManager.hypridle
            inputs.self.modules.homeManager.idle-inhibit-media
            inputs.self.modules.homeManager.vm-audio
            inputs.self.modules.homeManager.hyprpaper
            inputs.self.modules.homeManager.swaync
            inputs.self.modules.homeManager.waybar

            # CLI tools
            inputs.self.modules.homeManager.zsh
            inputs.self.modules.homeManager.tmux
            inputs.self.modules.homeManager.git
            inputs.self.modules.homeManager.lazygit
            inputs.self.modules.homeManager.neovim
            inputs.self.modules.homeManager.zoxide
            inputs.self.modules.homeManager.fzf
            inputs.self.modules.homeManager.bat
            inputs.self.modules.homeManager.eza
            inputs.self.modules.homeManager.yazi
            inputs.self.modules.homeManager.btop
            inputs.self.modules.homeManager.fastfetch
            inputs.self.modules.homeManager.oh-my-posh
            inputs.self.modules.homeManager.handlr-regex

            # Terminal
            inputs.self.modules.homeManager.ghostty

            # Media
            inputs.self.modules.homeManager.cava
            inputs.self.modules.homeManager.mpv
            inputs.self.modules.homeManager.zathura
            inputs.self.modules.homeManager.kdenlive

            # Productivity
            inputs.self.modules.homeManager.kdeconnect
            inputs.self.modules.homeManager.rofi

            # Development
            inputs.self.modules.homeManager.gpg
            inputs.self.modules.homeManager.opencode
            inputs.self.modules.homeManager.claude

            # Misc
            inputs.self.modules.homeManager.mime-apps
            inputs.self.modules.homeManager.packages
          ];

          home = {
            username = userName;
            homeDirectory = "/home/${userName}";
            stateVersion = "25.11";
          };

          xdg.enable = true;
        };
      };
    };
}
