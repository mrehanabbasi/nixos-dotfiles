# Neovim editor - symlinks to external config
{ ... }:

{
  flake.modules.nixos.neovim = { ... }: {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
    };
  };

  flake.modules.homeManager.neovim = { config, ... }: {
    xdg.configFile.nvim.source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/neovim-config";

    programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };
  };
}
