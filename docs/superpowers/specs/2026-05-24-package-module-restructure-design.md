# Package & Module Restructure Design

**Date:** 2026-05-24
**Branch:** main
**Scope:** Three phased improvements to package hygiene, module extractions, and structural Dendritic pattern compliance

---

## Context

Audit of the NixOS dotfiles repo revealed:
- Dendritic pattern adherence score: 7.5/10
- Core issues: no `mkEnableOption` anywhere, undeclared runtime deps, raw packages that should be modules, dead code, non-reproducible flake fetches
- Missing packages: DaVinci Resolve, several dev/media tools
- Redundant/orphaned packages: vlc, mpc, alsa-utils
- Suboptimal packages: webcord (use vesktop), wine (use wineWowPackages.stable)

---

## Phase 1 — Package Hygiene

### Remove from `packages.nix`
- `vlc` — redundant with configured mpv feature module
- `mpc` — orphaned, no MPD service configured anywhere
- `alsa-utils` — superseded by PipeWire tooling (wpctl, pavucontrol, qpwgraph)

### Replace
- `webcord` → `vesktop` in `packages.nix` — better Wayland screenshare via PipeWire, actively maintained, Vencord pre-bundled
- `wine` → `wineWowPackages.stable` in `wine.nix` — adds 32-bit support needed for winetricks and many Windows apps/games

### Declare undeclared runtime dependencies
Add `brightnessctl` and `playerctl` to `hyprland/default.nix` — both are used in Hyprland keybindings but declared nowhere. Co-locating them with the module that uses them is the correct Dendritic approach.

### Add to `packages.nix`
General tools:
- `delta` — syntax-highlighted git diff pager (complements git module)
- `shellcheck` — shell script linter (useful for .claude/hooks/ bash scripts)
- `shfmt` — shell script formatter
- `mediainfo` — video/audio metadata CLI (complements Kdenlive/ffmpeg stack)
- `ffmpegthumbnailer` — video thumbnails in yazi file previews
- `imagemagick` — image manipulation CLI, yazi preview support
- `nix-tree` — interactive Nix closure browser (directly useful for this repo)
- `age` — standalone encryption CLI for the existing sops/age setup

### Add to `go.nix`
- `delve` — Go debugger (significant gap for active Go development)
- `gotools` — `goimports`, `godoc`, `guru`, and other standard Go tools

### Fix nixpkgs-unstable imports in `go.nix` and `oh-my-posh.nix`
Both modules call `import inputs.nixpkgs-unstable { inherit (pkgs) system; }` without forwarding `config`. Fix to `inherit (pkgs) system config` to prevent silent `allowUnfree` failures if any unstable package becomes unfree.

### Fix `tmux.nix`
- Current `rev = "master"` for `tokyo-night-tmux` is non-reproducible
- Preferred: add `tokyo-night-tmux` as a flake input (check if upstream has a flake)
- Fallback: pin to a specific commit hash instead of `master`
- Keep Tokyo Night theme (intentional divergence from Catppuccin, user preference)

---

## Phase 2 — Module Extractions

All extracted modules follow the existing Dendritic pattern: registered as `flake.modules.nixos.<name>` or `flake.modules.homeManager.<name>`, added to `one-piece/default.nix` modules list.

### Extend `neovim.nix` — absorb LSP/tooling cluster
Move these 14 packages from `packages.nix` into the neovim feature module (they are neovim runtime dependencies, not general tools):
```
nil, nodePackages_latest.vscode-json-languageserver, yaml-language-server,
lua-language-server, docker-language-server, typescript,
typescript-language-server, tailwindcss-language-server, tree-sitter,
nodejs, bun, statix, markdownlint-cli2, addlicense
```

### New `modules/features/discord.nix`
- `vesktop` package
- Move the Hyprland `idleinhibit focus` window rule for webcord/vesktop out of `hyprland/default.nix` and into this module (keeps package + its Hyprland rule co-located)

### New `modules/features/communication.nix`
- `zoom-us`, `slack` packages
- Move their Hyprland `idleinhibit` window rules out of `hyprland/default.nix` into this module

### New `modules/features/notesnook.nix`
- `notesnook` package
- Follows pattern of other single-app modules (`localsend.nix`, `kdeconnect.nix`)

### New `modules/features/bitwarden.nix`
- `bitwarden-desktop` package (moved from `packages.nix`)
- `rbw` config (moved from `dank-material-shell/default.nix`)
- Both are parts of the same password-manager feature; co-locating them is cleaner

### New `modules/features/unity.nix`
- `unityhub` package
- Any FHS environment fixes needed for Unity on NixOS (investigate during implementation)

### New `modules/features/blender.nix`
- `blender` package
- GPU/CUDA environment variables for NVIDIA offload rendering

### Move to `core-packages.nix`
These are system-level build tools, not user-specific:
- `ripgrep`, `gnumake`, `just`, `zig`, `gcc`

---

## Phase 3 — Structural

### `mkEnableOption` on all modules
Every module in `features/`, `system/`, and `theming/` gets:
```nix
options.features.<name>.enable = lib.mkEnableOption "<description>";
config = lib.mkIf cfg.enable { ... };
```
Host profile (`one-piece/default.nix`) transitions from:
- Inclusion-based: `modules = [ inputs.self.modules.nixos.ghostty ... ]`
- To option-based: global import of all modules + `features.ghostty.enable = true`

New modules created in Phase 1 and Phase 2 are built with `mkEnableOption` from the start, so Phase 3 only retrofits existing modules.

Implementation order within Phase 3:
1. New modules (Phase 1+2 additions already have it)
2. `theming/` — lowest risk, fewest dependencies
3. `system/` — base, networking, etc.
4. `features/` — largest set, most complex
5. Host profile switch — final step once all modules have enable options

### New `modules/features/davinci-resolve.nix`
- `pkgs.davinci-resolve` (free tier, in nixpkgs proper)
- Unfree — add to `nixpkgs.config.allowUnfreePredicate` in `base.nix` if not already covered by predicate
- On hybrid AMD+NVIDIA: note that launching via `nvidia-offload davinci-resolve` is needed for GPU acceleration (the `enableOffloadCmd` in `gpu.nix` already exposes this wrapper)
- Optional Hyprland window rule for `class:^(resolve)$` if float/size behavior is desired
- No overlay or external flake input required

### Fix `secrets/default.nix` hardcoded user path
```nix
# Current (bad):
age.keyFile = "/home/rehan/.config/sops/age/keys.txt";

# Fix:
age.keyFile = "${config.users.users.rehan.home}/.config/sops/age/keys.txt";
```

### Fix `claude/default.nix` fragile path traversal
Current `../../../.claude/hooks/` traversals couple the module to its directory depth. Fix: copy hook files to `modules/features/claude/hooks/` so they are co-located with the module (matching how `gpg/default.nix` keeps `public-key.asc` adjacent).

### Fix dead code in `zsh.nix`
Delete the `oh-my-zsh` block with `enable = false` (lines ~75-92). Dead config that risks accidental re-enable.

### Fix duplicate `i18n.defaultLocale`
Remove from `one-piece/default.nix` — `base.nix` is the canonical location.

### Fix `_template/default.nix`
- Replace raw `./hardware.nix` path import with proper module reference
- Replace stale module names (`sddm`, `browsers`, `system-packages`) with current equivalents

### DMS greeter background fix
**Root cause (identified):** `greeterWallpaperPath` is set in the Home Manager DMS config (user session), but the greeter runs as a system service before any user session exists and does not read HM config. The NixOS greeter module only has `configFiles = [ "${./background.png}" ]` which copies the file but does not set it as the wallpaper.

**Investigation during implementation:**
1. Check `inputs.dms.nixosModules.greeter` option set for a NixOS-level wallpaper path option
2. If option exists: set `programs.dank-material-shell.greeter.wallpaperPath = "${./background.png}"` in `flake.modules.nixos.dms-greeter`
3. If no such option: write the wallpaper path into the greeter's config file directly via a `configFiles` entry with the correct config format that DMS greeter expects

### `dank-material-shell/default.nix` cleanup
After Phase 2 extracts `rbw` into `bitwarden.nix`:
- GTK theming (`gtk.theme.name`, `gtk.iconTheme`, dconf settings, GTK4 CSS) — evaluate if it belongs in `theming/` or stays here
- File should shrink significantly; remaining scope: DMS shell config + greeter NixOS module

---

## Validation

Each phase must pass before starting the next:

```bash
# After each phase:
nix eval .#nixosConfigurations.one-piece.config.system.build.toplevel
# Then dry-run:
nixos-rebuild dry-build --flake .#one-piece
```

Target config: `one-piece`. Validation host: `one-piece`. User runs `nixos-rebuild switch` — Claude only runs eval and dry-build.

---

## Files Affected (summary)

**Phase 1:**
- `modules/users/rehan/packages.nix`
- `modules/features/wine.nix`
- `modules/features/hyprland/default.nix`
- `modules/features/go.nix`
- `modules/features/oh-my-posh.nix`
- `modules/features/tmux.nix`
- `flake.nix` (if tokyo-night-tmux becomes flake input)
- `flake.lock`

**Phase 2:**
- `modules/features/neovim.nix` (extend)
- `modules/features/discord.nix` (new)
- `modules/features/communication.nix` (new)
- `modules/features/notesnook.nix` (new)
- `modules/features/bitwarden.nix` (new)
- `modules/features/unity.nix` (new)
- `modules/features/blender.nix` (new)
- `modules/system/core-packages.nix` (extend)
- `modules/features/hyprland/default.nix` (remove rules moved to discord/communication)
- `modules/features/dank-material-shell/default.nix` (remove rbw section)
- `modules/hosts/one-piece/default.nix` (add new modules to list)
- `modules/users/rehan/packages.nix` (remove extracted packages)

**Phase 3:**
- All files under `modules/features/`, `modules/system/`, `modules/theming/` (mkEnableOption)
- `modules/hosts/one-piece/default.nix` (host profile restructure)
- `modules/features/davinci-resolve.nix` (new)
- `modules/secrets/default.nix`
- `modules/features/claude/default.nix` + new `hooks/` subdir
- `modules/features/zsh.nix`
- `modules/system/base.nix`
- `modules/hosts/_template/default.nix`
- `modules/features/dank-material-shell/default.nix` (GTK cleanup)
