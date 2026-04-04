# Flake-parts infrastructure setup
{ inputs, ... }:

{
  imports = [
    inputs.flake-parts.flakeModules.modules
  ];

  systems = [
    "x86_64-linux"
  ];

  # Export modules as flakeModules to suppress warning
  flake.flakeModules = inputs.self.modules or { };

  # perSystem for per-system outputs
  perSystem =
    { pkgs, ... }:
    {
      # Formatter (accessible via `nix fmt`)
      formatter = pkgs.nixfmt-rfc-style;

      # Custom packages (accessible via self'.packages.*)
      packages = {
        # Custom packages can be defined here
      };

      # Development shell (accessible via `nix develop`)
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          nixfmt-rfc-style
          nil
          statix
        ];
      };
    };
}
