# Context7 MCP - AI documentation server
_:

{
  flake.modules.nixos.context7 =
    { config, lib, ... }:
    let
      cfg = config.features.context7;
    in
    {
      options.features.context7.enable = lib.mkEnableOption "Context7 MCP documentation server";

      config = lib.mkIf cfg.enable {
        sops.secrets.context7_api_key = {
          format = "yaml";
          owner = "rehan";
        };
      };
    };

  flake.modules.homeManager.context7 =
    { config, lib, ... }:
    let
      cfg = config.features.context7;
    in
    {
      options.features.context7.enable = lib.mkEnableOption "Context7 MCP documentation server";

      config = lib.mkIf cfg.enable {
        programs.zsh.initContent = lib.mkBefore ''
          [[ -r /run/secrets/context7_api_key ]] && export CONTEXT7_API_KEY=$(<"/run/secrets/context7_api_key")
        '';
      };
    };
}
