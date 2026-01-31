# KDE Connect - phone connectivity
_:

{
  flake.modules.nixos.kdeconnect =
    _:
    {
      programs.kdeconnect.enable = true;
    };

  flake.modules.homeManager.kdeconnect =
    _:
    {
      services.kdeconnect = {
        enable = true;
        indicator = true;
      };
    };
}
