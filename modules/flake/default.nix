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
}
