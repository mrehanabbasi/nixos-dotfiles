# Zoxide - smarter cd command
_:

{
  flake.modules.homeManager.zoxide = _: {
    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
      options = [ "--cmd cd" ];
    };
  };
}
