# User configuration
{ pkgs, ... }:

{
  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.rehan = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "podman"
      "input"
      "uinput"
      "network"
      "networkmanager"
    ];
    shell = pkgs.zsh;
    packages = with pkgs; [
      tree
    ];
  };
}
