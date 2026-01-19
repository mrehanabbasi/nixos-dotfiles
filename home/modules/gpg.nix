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

  # Ensure GPG agent uses the correct TTY for pinentry-tty
  # This is required for GPG signing to work in CLI tools like Claude Code
  services.gpg-agent = {
    enable = true;
    enableZshIntegration = true;
  };
}
