# Go development environment
# Uses nixpkgs-unstable for latest versions
{ inputs, ... }:

{
  flake.modules.homeManager.go =
    { config, pkgs, ... }:
    let
      pkgs-unstable = import inputs.nixpkgs-unstable { inherit (pkgs) system; };
    in
    {
      home.packages = with pkgs-unstable; [
        go
        gopls
        gofumpt
        golangci-lint
      ];

      home.sessionPath = [ "${config.home.homeDirectory}/go/bin" ];
    };
}
