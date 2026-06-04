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
            inputs.voxtype.homeManagerModules.default

            # Theming
            inputs.self.modules.homeManager.catppuccin

            # Desktop
            inputs.self.modules.homeManager.hyprland
            inputs.self.modules.homeManager.vm-audio
            inputs.self.modules.homeManager.dank-material-shell

            # CLI tools
            inputs.self.modules.homeManager.zsh
            inputs.self.modules.homeManager.tmux
            inputs.self.modules.homeManager.sesh
            inputs.self.modules.homeManager.git
            inputs.self.modules.homeManager.lazygit
            inputs.self.modules.homeManager.neovim
            inputs.self.modules.homeManager.zoxide
            inputs.self.modules.homeManager.fzf
            inputs.self.modules.homeManager.doppler
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
            inputs.self.modules.homeManager.mpv
            inputs.self.modules.homeManager.zathura
            inputs.self.modules.homeManager.kdenlive
            inputs.self.modules.homeManager.voxtype

            # Productivity
            inputs.self.modules.homeManager.notesnook
            inputs.self.modules.homeManager.kdeconnect
            inputs.self.modules.homeManager.bitwarden

            # Browsers
            inputs.self.modules.homeManager.librewolf

            # Development
            inputs.self.modules.homeManager.context7
            inputs.self.modules.homeManager.go
            inputs.self.modules.homeManager.gpg
            inputs.self.modules.homeManager.opencode
            inputs.self.modules.homeManager.claude
            inputs.self.modules.homeManager.gemini-cli
            inputs.self.modules.homeManager.pre-commit

            # Communication
            inputs.self.modules.homeManager.communication
            inputs.self.modules.homeManager.discord
            inputs.self.modules.homeManager.protonmail-desktop
            inputs.self.modules.homeManager.fastmail-desktop

            # Creative tools
            inputs.self.modules.homeManager.unity
            inputs.self.modules.homeManager.blender

            # Misc
            inputs.self.modules.homeManager.mime-apps
            inputs.self.modules.homeManager.packages
          ];

          features.catppuccin.enable = true;
          features.communication.enable = true;
          features.discord.enable = true;
          features.protonmail-desktop.enable = true;
          features.fastmail-desktop.enable = true;
          features.notesnook.enable = true;
          features.bitwarden.enable = true;
          features.unity.enable = true;
          features.blender.enable = true;
          features.bat.enable = true;
          features.btop.enable = true;
          features.doppler.enable = true;
          features.eza.enable = true;
          features.fastfetch.enable = true;
          features.fzf.enable = true;
          features."gemini-cli".enable = true;
          features.ghostty.enable = true;
          features."handlr-regex".enable = true;
          features.kdenlive.enable = true;
          features.lazygit.enable = true;
          features.librewolf.enable = true;
          features."mime-apps".enable = true;
          features.mpv.enable = true;
          features.opencode.enable = true;
          features."pre-commit".enable = true;
          features.voxtype.enable = true;
          features."vm-audio".enable = true;
          features.yazi.enable = true;
          features.zathura.enable = true;
          features.zoxide.enable = true;
          features.context7.enable = true;
          features.go.enable = true;
          features."oh-my-posh".enable = true;
          features.zsh.enable = true;
          features.neovim.enable = true;
          features.tmux.enable = true;
          features.sesh.enable = true;
          features.hyprland.enable = true;
          features.kdeconnect.enable = true;
          features.git.enable = true;
          features.gpg.enable = true;
          features.claude.enable = true;
          features."dank-material-shell".enable = true;
          features.packages.enable = true;

          home = {
            username = userName;
            homeDirectory = "/home/${userName}";
            stateVersion = "26.05";
          };

          xdg.enable = true;
        };
      };
    };
}
