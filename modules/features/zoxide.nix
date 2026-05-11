# Zoxide - smarter cd command
# Must init after oh-my-posh to prevent precmd_functions hook displacement
{ lib, ... }:

{
  flake.modules.homeManager.zoxide =
    { config, ... }:
    {
      programs.zoxide = {
        enable = true;
        options = [ "--cmd cd" ];
        enableZshIntegration = false;
      };

      programs.zsh.initContent = lib.mkOrder 2000 ''
        eval "$(zoxide init zsh ${lib.concatStringsSep " " config.programs.zoxide.options})"
      '';
  };
}
