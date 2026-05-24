# Neovim editor - symlinks to external config
_:

{
  flake.modules.nixos.neovim = _: {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
    };
  };

  flake.modules.homeManager.neovim =
    { config, pkgs, ... }:
    {
      xdg.configFile.nvim.source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/neovim-config";

      programs.neovim = {
        enable = true;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;
      };

      # LSPs, formatters, and build tools used by neovim plugins at runtime
      home.packages = with pkgs; [
        nil
        nodePackages_latest.vscode-json-languageserver
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
}
