# Helper functions for creating NixOS configurations
# This file is NOT auto-imported (underscore prefix)
{ inputs }:

{
  # Create a NixOS configuration from a list of modules
  mkNixos =
    {
      system,
      modules,
    }:
    inputs.nixpkgs.lib.nixosSystem {
      modules = modules ++ [
        { nixpkgs.hostPlatform = system; }
      ];
      specialArgs = { inherit inputs; };
    };
}
