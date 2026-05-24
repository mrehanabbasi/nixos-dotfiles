# Go development environment
# Uses nixpkgs-unstable for latest versions
{ inputs, ... }:

{
  flake.modules.homeManager.go =
    { config, pkgs, ... }:
    let
      pkgs-unstable = import inputs.nixpkgs-unstable { inherit (pkgs) system config; };
    in
    {
      home.packages = with pkgs-unstable; [
        go
        gopls
        gofumpt
        golangci-lint
        delve
        gotools
      ];

      home.sessionPath = [ "${config.home.homeDirectory}/go/bin" ];
    };
}
