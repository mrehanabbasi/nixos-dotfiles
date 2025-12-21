{ ... }:

{
  sops = {
    defaultSopsFile = "${./secrets/secrets.yaml}";
    defaultSopsFormat = "yaml";

    age.keyFile = "/home/rehan/.config/sops/age/keys.txt";

    secrets.pia = {
      format = "yaml";
      # sopsFile = "${./secrets/secrets.yaml}";
    };
  };
}
