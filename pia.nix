{ config, ... }:

{
  services.pia = {
    enable = true;
    credentials = {
      credentialsFile = config.sops.secrets.pia.path;
    };
    protocol = "wireguard";
  };
}
