# Zoxide - smarter cd command
{ ... }:

{
  flake.modules.homeManager.zoxide = { ... }: {
    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
      options = [ "--cmd cd" ];
    };
  };
}
