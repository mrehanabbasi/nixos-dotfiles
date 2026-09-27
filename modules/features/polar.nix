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

        # Upstream publishes a linux-x64 tarball only; there is no aarch64
        # release to fall back to. Recorded here so the platform mismatch is
        # a clear assertion rather than a patchelf failure mid-build.
        meta.platforms = [ "x86_64-linux" ];
      };
    in
    {
      options.features.polar.enable = lib.mkEnableOption "Polar.sh CLI";

      config = lib.mkIf cfg.enable {
        assertions = [
          {
            assertion = pkgs.stdenv.hostPlatform.isx86_64;
            message = "features.polar: upstream ships a linux-x64 binary only, nothing for ${pkgs.stdenv.hostPlatform.system}.";
          }
        ];

        home.packages = [ polar-cli ];
      };
    };
}
