# AppImage support
# Enables running AppImage files directly via binfmt
_:

{
  flake.modules.nixos.appimage = _: {
    programs.appimage = {
      enable = true;
      binfmt = true;
    };
  };
}
