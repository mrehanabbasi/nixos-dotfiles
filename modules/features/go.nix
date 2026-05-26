# Go development environment
# Uses nixpkgs-unstable for latest versions
{ inputs, ... }:

{
  flake.modules.homeManager.go =
    { config, lib, pkgs, ... }:
    let
      cfg = config.features.go;
      pkgs-unstable = import inputs.nixpkgs-unstable { inherit (pkgs.stdenv.hostPlatform) system; inherit (pkgs) config; };
    in
    {
      options.features.go.enable = lib.mkEnableOption "Go development environment";

      config = lib.mkIf cfg.enable {
        home.packages = with pkgs-unstable; [
          go
          gopls
          gofumpt
          golangci-lint
          delve
          (lib.meta.lowPrio gotools) # lower priority to resolve modernize conflict with gopls
        ];

        home.sessionPath = [ "${config.home.homeDirectory}/go/bin" ];
      };
    };
}
