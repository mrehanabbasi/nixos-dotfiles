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
            inputs.self.modules.homeManager.hypr-cheatsheet
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
            inputs.self.modules.homeManager.gimp

            # Productivity
            inputs.self.modules.homeManager.notesnook
            inputs.self.modules.homeManager.obsidian
            inputs.self.modules.homeManager.kdeconnect
            inputs.self.modules.homeManager.bitwarden

            # Browsers
            inputs.self.modules.homeManager.librewolf

            # Development
            inputs.self.modules.homeManager.context7
            inputs.self.modules.homeManager.cliproxyapi
            inputs.self.modules.homeManager.go
            inputs.self.modules.homeManager.gpg
            inputs.self.modules.homeManager.opencode
            inputs.self.modules.homeManager.claude
            inputs.self.modules.homeManager.codex
            inputs.self.modules.homeManager.gemini-cli
            inputs.self.modules.homeManager.chatgpt
            inputs.self.modules.homeManager.polar
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

          features = {
            catppuccin.enable = true;
            communication.enable = true;
            discord.enable = true;
            protonmail-desktop.enable = true;
            fastmail-desktop.enable = true;
            notesnook.enable = true;
            obsidian.enable = true;
            bitwarden.enable = true;
            unity.enable = true;
            blender.enable = true;
            bat.enable = true;
            btop.enable = true;
            doppler.enable = true;
            eza.enable = true;
            fastfetch.enable = true;
            fzf.enable = true;
            codex.enable = true;
            "gemini-cli".enable = true;
            chatgpt.enable = true;
            polar.enable = true;
            ghostty.enable = true;
            "handlr-regex".enable = true;
            kdenlive.enable = true;
            gimp.enable = true;
            lazygit.enable = true;
            librewolf.enable = true;
            "mime-apps".enable = true;
            mpv.enable = true;
            opencode.enable = true;
            "pre-commit".enable = true;
            voxtype.enable = true;
            "vm-audio".enable = true;
            yazi.enable = true;
            zathura.enable = true;
            zoxide.enable = true;
            context7.enable = true;
            cliproxyapi.enable = true;
            go.enable = true;
            "oh-my-posh".enable = true;
            zsh.enable = true;
            neovim.enable = true;
            tmux.enable = true;
            sesh.enable = true;
            hyprland.enable = true;
            "hypr-cheatsheet".enable = true;
            kdeconnect.enable = true;
            git.enable = true;
            gpg.enable = true;
            claude.enable = true;
            "dank-material-shell".enable = true;
            packages.enable = true;
          };

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
