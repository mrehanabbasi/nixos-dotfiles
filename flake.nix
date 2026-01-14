{
  description = "Hyprland on NixOS";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprshutdown = {
      url = "github:hyprwm/hyprshutdown";
      # Let hyprshutdown use its own nixpkgs (unstable) to avoid compatibility issues
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin = {
      # url = "github:catppuccin/nix/release-25.05";
      url = "github:catppuccin/nix"; # Supports eza
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    opencode = {
      url = "github:anomalyco/opencode";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pia = {
      url = "github:mrehanabbasi/pia.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      hyprshutdown,
      catppuccin,
      sops-nix,
      opencode,
      pia,
      ...
    }:
    {
      nixosConfigurations.one-piece = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit hyprshutdown opencode;
        };
        modules = [
          catppuccin.nixosModules.catppuccin
          pia.nixosModules.default
          ./configuration.nix
          sops-nix.nixosModules.sops
          ./sops.nix
          ./pia.nix

          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = {
                inherit opencode;
              };
              users.rehan = {
                imports = [
                  ./home/home.nix
                  catppuccin.homeModules.catppuccin
                ];
              };
              # sharedModules = [
              #   sops-nix.homeManagerModules.sops
              # ];
            };
          }
        ];
      };
    };
}
