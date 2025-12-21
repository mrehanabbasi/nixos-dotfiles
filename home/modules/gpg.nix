{ ... }:

{
  programs.gpg = {
    enable = true;
    publicKeys = [
      {
        source = "${../../keys/gpg-key.asc}";
        trust = "ultimate";
      }
    ];
  };
}
