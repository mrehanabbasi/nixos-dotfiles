# pre-commit - Git pre-commit hooks framework
_:

{
  flake.modules.homeManager.pre-commit =
    { config, lib, pkgs, ... }:
    let
      cfg = config.features."pre-commit";
    in
    {
      options.features."pre-commit".enable = lib.mkEnableOption "pre-commit git hooks framework";
      config = lib.mkIf cfg.enable {
        home.packages = [ pkgs.pre-commit ];
      };
    };
}
