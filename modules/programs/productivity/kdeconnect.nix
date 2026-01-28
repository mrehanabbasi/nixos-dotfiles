# KDE Connect - phone connectivity
{ ... }:

{
  flake.modules.nixos.kdeconnect =
    { ... }:
    {
      programs.kdeconnect.enable = true;
    };

  flake.modules.homeManager.kdeconnect =
    { ... }:
    {
      services.kdeconnect = {
        enable = true;
        indicator = true;
      };
    };
}
