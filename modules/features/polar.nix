_:

{
  flake.modules.homeManager.polar =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.features.polar;

      polar-cli = pkgs.stdenv.mkDerivation {
        pname = "polar";
        version = "1.3.6";

        src = pkgs.fetchurl {
          url = "https://github.com/polarsource/cli/releases/download/v1.3.6/polar-linux-x64.tar.gz";
          sha256 = "0x3q8qjb47as164l1p7j7051v9c7z5ia1c5l9b7vbaa47a2lvdin";
        };

        nativeBuildInputs = [ pkgs.patchelf ];

        sourceRoot = ".";
        dontStrip = true;
        dontPatchELF = true;

        installPhase = ''
          runHook preInstall
          mkdir -p $out/bin
          install -m755 polar $out/bin/polar
          patchelf --set-interpreter "$(cat ${pkgs.stdenv.cc}/nix-support/dynamic-linker)" $out/bin/polar
          runHook postInstall
        '';
      };
    in
    {
      options.features.polar.enable = lib.mkEnableOption "Polar.sh CLI";

      config = lib.mkIf cfg.enable {
        home.packages = [ polar-cli ];
      };
    };
}
