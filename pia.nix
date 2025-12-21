{ config, ... }:

{
  services.pia = {
    enable = true;
    authUserPassFile = config.sops.secrets.pia.path;
  };
}
