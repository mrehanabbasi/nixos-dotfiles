{
  description = "Claude Code - AI coding assistant from Anthropic";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      # Claude Code version and hashes from official manifest
      # Update these when upgrading: fetch manifest.json from
      # https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/{VERSION}/manifest.json
      version = "2.1.39";
      hashes = {
        # Update hashes by running: nix-prefetch-url <url> | nix hash convert --to sri
        "x86_64-linux" = "sha256-aOR3Wyk9leBtFoWBxSP8XBUjloF5Ip0xoCnyhbKs6v8=";
        "aarch64-linux" = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Update if needed
        "x86_64-darwin" = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Update if needed
        "aarch64-darwin" = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Update if needed
      };
      platforms = {
        "x86_64-linux" = "linux-x64";
        "aarch64-linux" = "linux-arm64";
        "x86_64-darwin" = "darwin-x64";
        "aarch64-darwin" = "darwin-arm64";
      };

      supportedSystems = builtins.attrNames platforms;

      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      mkPackage =
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          platform = platforms.${system};
          hash = hashes.${system};

          baseUrl = "https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases";
        in
        pkgs.stdenv.mkDerivation {
          pname = "claude-code";
          inherit version;

          src = pkgs.fetchurl {
            url = "${baseUrl}/${version}/${platform}/claude";
            inherit hash;
          };

          # No source unpacking needed - it's a single binary
          dontUnpack = true;

          nativeBuildInputs =
            pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux [
              pkgs.autoPatchelfHook
            ]
            ++ [ pkgs.makeWrapper ];

          buildInputs = pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux [
            pkgs.stdenv.cc.cc.lib
            pkgs.zlib
          ];

          # Runtime dependencies
          propagatedBuildInputs = [
            pkgs.ripgrep
          ];

          installPhase = ''
            runHook preInstall

            mkdir -p $out/bin
            cp $src $out/bin/claude
            chmod +x $out/bin/claude

            runHook postInstall
          '';

          # Disable auto-updates in Nix environment
          postFixup = ''
            wrapProgram $out/bin/claude \
              --set DISABLE_AUTOUPDATER 1 \
              --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.ripgrep ]}
          '';

          meta = {
            description = "Agentic coding tool that lives in your terminal";
            homepage = "https://github.com/anthropics/claude-code";
            license = pkgs.lib.licenses.unfree;
            platforms = supportedSystems;
            mainProgram = "claude";
          };
        };
    in
    {
      packages = forAllSystems (system: {
        default = mkPackage system;
        claude-code = mkPackage system;
      });

      overlays.default = final: prev: {
        claude-code = self.packages.${final.system}.default;
      };
    };
}
