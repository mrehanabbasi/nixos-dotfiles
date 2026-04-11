{
  description = "NixOS Dendritic Configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    opencode = {
      url = "github:anomalyco/opencode?ref=latest";
      # Don't follow nixpkgs - opencode needs newer bun (^1.3.11) than stable provides
    };

    pia = {
      url = "github:mrehanabbasi/pia.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Note: nix-flatpak doesn't have a nixpkgs input to follow
    nix-flatpak.url = "github:gmodena/nix-flatpak";

    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dms-plugin-registry = {
      url = "github:AvengeMedia/dms-plugin-registry";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dgop = {
      url = "github:AvengeMedia/dgop";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    voxtype = {
      url = "github:peteonrails/voxtype";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # Custom importTree that imports ALL .nix files (not just default.nix)
  # Excludes: flake.nix, _ prefixed files, and files in _ prefixed directories
  outputs =
    inputs:
    let
      inherit (inputs.nixpkgs) lib;

      # Recursively find all .nix files, excluding _ prefixed paths
      findNixFiles =
        dir:
        lib.flatten (
          lib.mapAttrsToList (
            name: type:
            if lib.hasPrefix "_" name then
              [ ] # Skip _ prefixed entries
            else if type == "directory" then
              findNixFiles (dir + "/${name}")
            else if type == "regular" && lib.hasSuffix ".nix" name && name != "flake.nix" then
              [ (dir + "/${name}") ]
            else
              [ ]
          ) (builtins.readDir dir)
        );

      importTree = findNixFiles;
    in
    inputs.flake-parts.lib.mkFlake { inherit inputs; } { imports = importTree ./modules; };
}
