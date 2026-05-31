# Neovim editor - symlinks to external config
_:

{
  flake.modules.nixos.neovim =
    { config, lib, ... }:
    let
      cfg = config.features.neovim;
    in
    {
      options.features.neovim.enable = lib.mkEnableOption "neovim editor";

      config = lib.mkIf cfg.enable {
        programs.neovim = {
          enable = true;
          defaultEditor = true;
        };
      };
    };

  flake.modules.homeManager.neovim =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.features.neovim;
    in
    {
      options.features.neovim.enable = lib.mkEnableOption "neovim editor";

      config = lib.mkIf cfg.enable {
        # External nvim config managed via symlink; NixOS module enables nvim
        # system-wide so HM does not set programs.neovim here (would conflict
        # with the symlink by trying to write init.lua through it).
        xdg.configFile.nvim.source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/neovim-config";

        home.sessionVariables.EDITOR = "nvim";
        home.shellAliases = {
          vi = "nvim";
          vim = "nvim";
          vimdiff = "nvim -d";
        };

        # LSPs, formatters, and build tools used by neovim plugins at runtime
        home.packages = with pkgs; [
          nil
          vscode-json-languageserver
          yaml-language-server
          lua-language-server
          docker-language-server
          typescript
          typescript-language-server
          tailwindcss-language-server
          tree-sitter
          nodejs
          bun
          statix
          markdownlint-cli2
          addlicense
        ];
      };
    };
}
