# pre-commit - Git pre-commit hooks framework
_:

{
  flake.modules.homeManager.pre-commit =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.pre-commit ];
    };
}
