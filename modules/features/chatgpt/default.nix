# ChatGPT desktop client (official OpenAI Linux build)
#
# nixpkgs' `chatgpt` is macOS-only - it unpacks the darwin .zip and is marked
# `platforms = lib.platforms.darwin`. OpenAI shipped the Linux app (.deb/.rpm)
# in August 2026, but Linux support is still an unmerged nixpkgs PR:
#
#   https://github.com/NixOS/nixpkgs/pull/551713  @ 294e967ba4b504cec68ab969c8850f01dd8433c2
#
# _pkg/ is that PR's `pkgs/by-name/ch/chatgpt` vendored verbatim, minus the
# `passthru.updateScript = ./update.sh` line (update.sh is not vendored).
# It is callPackage'd from nixpkgs-unstable, so every dependency it pulls
# (codex, tectonic-unwrapped, nodejs-slim, qt6, ...) resolves against the
# pinned unstable input and substitutes from cache.nixos.org.
#
# When the PR lands: delete _pkg/ and use `pkgs-unstable.chatgpt` directly.
{ inputs, ... }:

{
  flake.modules.homeManager.chatgpt =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.features.chatgpt;
      pkgs-unstable = import inputs.nixpkgs-unstable {
        inherit (pkgs.stdenv.hostPlatform) system;
        inherit (pkgs) config;
      };
      chatgpt = pkgs-unstable.callPackage ./_pkg/package.nix { };
    in
    {
      options.features.chatgpt.enable = lib.mkEnableOption "ChatGPT desktop client";

      config = lib.mkIf cfg.enable {
        home.packages = [ chatgpt ];
      };
    };
}
