# Audio configuration with Pipewire
_:

{
  flake.modules.nixos.audio =
    _:
    {
      services.pipewire = {
        enable = true;
        audio.enable = true;
        pulse.enable = true;
        alsa = {
          enable = true;
          support32Bit = true;
        };
        jack.enable = true;
        wireplumber.enable = true;
      };
    };
}
