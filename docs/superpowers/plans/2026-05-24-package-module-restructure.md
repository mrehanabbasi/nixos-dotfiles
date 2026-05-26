# Package & Module Restructure Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Improve package hygiene, extract packages into feature modules, and add `mkEnableOption` to all modules for option-based host configuration.

**Architecture:** Three sequential phases — Phase 1 cleans up packages.nix and fixes reproducibility issues; Phase 2 extracts package clusters into dedicated feature modules (all new modules include `mkEnableOption` from the start); Phase 3 retrofits `mkEnableOption` onto all existing modules and restructures the host profile.

**Tech Stack:** Nix/NixOS flake-parts Dendritic pattern. All modules registered as `flake.modules.nixos.<name>` or `flake.modules.homeManager.<name>`. New NixOS modules added to `modules/hosts/one-piece/default.nix`. New HM modules added to `modules/users/rehan/default.nix`.

---

## Validation Baseline

**Target config:** one-piece. **Validation host:** one-piece. **Planned verification:**

```bash
nix eval .#nixosConfigurations.one-piece.config.system.build.toplevel
nixos-rebuild dry-build --flake .#one-piece
```

Run this after every phase (not every task) before proceeding. The user runs `nixos-rebuild switch`; Claude only runs `nix eval` and `dry-build`.

---

## mkEnableOption Pattern Reference

Every new module in Phase 2 and every retrofitted module in Phase 3 uses this exact pattern:

```nix
# For a module with ONLY homeManager aspect:
_:
{
  flake.modules.homeManager.foo =
    { config, lib, pkgs, ... }:
    let
      cfg = config.features.foo;
    in
    {
      options.features.foo.enable = lib.mkEnableOption "foo description";
      config = lib.mkIf cfg.enable {
        # ... actual config
      };
    };
}

# For a module with ONLY nixos aspect:
_:
{
  flake.modules.nixos.foo =
    { config, lib, pkgs, ... }:
    let
      cfg = config.features.foo;
    in
    {
      options.features.foo.enable = lib.mkEnableOption "foo description";
      config = lib.mkIf cfg.enable {
        # ... actual config
      };
    };
}

# For a module with BOTH nixos AND homeManager aspects:
_:
{
  flake.modules.nixos.foo =
    { config, lib, ... }:
    let
      cfg = config.features.foo;
    in
    {
      options.features.foo.enable = lib.mkEnableOption "foo description";
      config = lib.mkIf cfg.enable {
        # ... nixos config
      };
    };

  flake.modules.homeManager.foo =
    { config, lib, pkgs, ... }:
    let
      cfg = config.features.foo;
    in
    {
      options.features.foo.enable = lib.mkEnableOption "foo description";
      config = lib.mkIf cfg.enable {
        # ... hm config
      };
    };
}
```

For modules that use `{ inputs, ... }:` at the top level (e.g. go.nix, dank-material-shell), keep that outer function and add `config`/`lib` to the inner module function:

```nix
{ inputs, ... }:
{
  flake.modules.homeManager.go =
    { config, lib, pkgs, ... }:
    let
      cfg = config.features.go;
      pkgs-unstable = import inputs.nixpkgs-unstable { inherit (pkgs) system config; };
    in
    {
      options.features.go.enable = lib.mkEnableOption "Go development environment";
      config = lib.mkIf cfg.enable {
        # ...
      };
    };
}
```

---

## PHASE 1 — Package Hygiene

---

### Task 1: Remove dead packages from packages.nix

**Files:**
- Modify: `modules/users/rehan/packages.nix`

- [ ] **Step 1: Remove vlc, mpc, alsa-utils from packages.nix**

  `modules/users/rehan/packages.nix` — remove these three lines from `home.packages`:
  ```
  vlc
  mpc
  alsa-utils
  ```

- [ ] **Step 2: Replace webcord with vesktop**

  In `modules/users/rehan/packages.nix`, change:
  ```nix
  webcord
  ```
  to:
  ```nix
  vesktop
  ```

- [ ] **Step 3: Eval**

  ```bash
  nix eval .#nixosConfigurations.one-piece.config.system.build.toplevel
  ```
  Expected: evaluates without error (no attribute error for the removed packages).

- [ ] **Step 4: Commit**

  ```bash
  git add modules/users/rehan/packages.nix
  git commit -m "fix(packages): remove dead pkgs, webcord→vesktop"
  ```

---

### Task 2: Add new utility packages to packages.nix

**Files:**
- Modify: `modules/users/rehan/packages.nix`

- [ ] **Step 1: Add new packages**

  In `modules/users/rehan/packages.nix`, append to `home.packages`:
  ```nix
  # Git/shell tooling
  delta
  shellcheck
  shfmt

  # Media utilities
  mediainfo
  ffmpegthumbnailer
  imagemagick

  # Nix tooling
  nix-tree

  # Encryption
  age
  ```

  Final state of `modules/users/rehan/packages.nix`:
  ```nix
  # User-specific packages for rehan
  _:

  {
    flake.modules.homeManager.packages =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          # Core utilities (not managed by feature modules)
          ripgrep
          nixfmt-rfc-style
          gcc

          # Fonts (nerd-fonts.jetbrains-mono is in system/fonts.nix)
          noto-fonts
          nerd-fonts.iosevka
          icomoon-feather

          # Media utilities
          imv
          mediainfo
          ffmpegthumbnailer
          imagemagick

          # Neovim-related (LSPs, formatters, build tools)
          gnumake
          just
          zig
          nil
          nodePackages_latest.vscode-json-languageserver
          yaml-language-server
          lua-language-server
          docker-language-server
          typescript
          typescript-language-server
          tailwindcss-language-server
          tree-sitter
          nodejs
          bun
          statix # nix linter
          markdownlint-cli2
          addlicense

          # CLI tools
          gh
          jq
          jless
          yq

          # Git/shell tooling
          delta
          shellcheck
          shfmt

          # Nix tooling
          nix-tree

          # Encryption
          age

          # Applications
          vesktop
          bitwarden-desktop
          notesnook
          claude-code
          blender
          unityhub

          # Communication
          zoom-us
          slack
        ];

        home.pointerCursor = {
          size = 24;
        };
      };
  }
  ```

- [ ] **Step 2: Eval**

  ```bash
  nix eval .#nixosConfigurations.one-piece.config.system.build.toplevel
  ```

- [ ] **Step 3: Commit**

  ```bash
  git add modules/users/rehan/packages.nix
  git commit -m "feat(packages): add delta, shellcheck, shfmt, mediainfo, ffmpegthumbnailer, imagemagick, nix-tree, age"
  ```

---

### Task 3: Fix wine.nix — wine → wineWowPackages.stable

**Files:**
- Modify: `modules/features/wine.nix`

- [ ] **Step 1: Replace wine with wineWowPackages.stable**

  `modules/features/wine.nix` — full new content:
  ```nix
  # Wine - Windows compatibility layer and gaming tools
  _:

  {
    flake.modules.nixos.wine =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          # Wine and tools (wineWowPackages.stable adds 32-bit support for winetricks)
          wineWowPackages.stable
          winetricks
          # Game launchers
          lutris
          heroic
          bottles
          # Proton management
          protonup-qt
        ];
      };
  }
  ```

- [ ] **Step 2: Eval**

  ```bash
  nix eval .#nixosConfigurations.one-piece.config.system.build.toplevel
  ```

- [ ] **Step 3: Commit**

  ```bash
  git add modules/features/wine.nix
  git commit -m "fix(wine): wine → wineWowPackages.stable for 32-bit support"
  ```

---

### Task 4: Declare brightnessctl and playerctl in hyprland/default.nix

**Files:**
- Modify: `modules/features/hyprland/default.nix`

- [ ] **Step 1: Add runtime dependencies to NixOS hyprland module**

  In `modules/features/hyprland/default.nix`, extend the `flake.modules.nixos.hyprland` block. Add a `home.packages` section (it already has `environment.systemPackages`). Actually, since these are tools called from keybindings, they should be in `environment.systemPackages` (NixOS-level):

  In the `flake.modules.nixos.hyprland` block, add `brightnessctl` and `playerctl` to `environment.systemPackages`:
  ```nix
  flake.modules.nixos.hyprland =
    { pkgs, ... }:
    {
      programs.hyprland = {
        enable = true;
        xwayland.enable = true;
      };

      programs.hyprlock.enable = true;
      services.hypridle.enable = true;

      security.polkit.enable = true;
      security.pam.services.hyprlock = { };

      environment.systemPackages = with pkgs; [
        hyprpaper
        hyprshot
        hyprpicker
        # Runtime deps for Hyprland keybindings
        brightnessctl
        playerctl
      ];

      # Note: gvfs.enable is in thunar.nix
      services.upower.enable = true;
    };
  ```

- [ ] **Step 2: Eval**

  ```bash
  nix eval .#nixosConfigurations.one-piece.config.system.build.toplevel
  ```

- [ ] **Step 3: Commit**

  ```bash
  git add modules/features/hyprland/default.nix
  git commit -m "fix(hyprland): declare brightnessctl, playerctl as runtime deps"
  ```

---

### Task 5: Add delve and gotools to go.nix

**Files:**
- Modify: `modules/features/go.nix`

- [ ] **Step 1: Add delve and gotools, also fix nixpkgs-unstable inherit**

  `modules/features/go.nix` — full new content (also fixes the `config` inherit issue from Task 6):
  ```nix
  # Go development environment
  # Uses nixpkgs-unstable for latest versions
  { inputs, ... }:

  {
    flake.modules.homeManager.go =
      { config, pkgs, ... }:
      let
        pkgs-unstable = import inputs.nixpkgs-unstable { inherit (pkgs) system config; };
      in
      {
        home.packages = with pkgs-unstable; [
          go
          gopls
          gofumpt
          golangci-lint
          delve
          gotools
        ];

        home.sessionPath = [ "${config.home.homeDirectory}/go/bin" ];
      };
  }
  ```

- [ ] **Step 2: Eval**

  ```bash
  nix eval .#nixosConfigurations.one-piece.config.system.build.toplevel
  ```

- [ ] **Step 3: Commit**

  ```bash
  git add modules/features/go.nix
  git commit -m "feat(go): add delve, gotools; fix nixpkgs-unstable config inherit"
  ```

---

### Task 6: Fix nixpkgs-unstable config inherit in oh-my-posh.nix

**Files:**
- Modify: `modules/features/oh-my-posh.nix`

- [ ] **Step 1: Fix inherit**

  In `modules/features/oh-my-posh.nix`, change line 9 from:
  ```nix
  pkgs-unstable = import inputs.nixpkgs-unstable { inherit (pkgs) system; };
  ```
  to:
  ```nix
  pkgs-unstable = import inputs.nixpkgs-unstable { inherit (pkgs) system config; };
  ```

  Also update the inner module function signature to include `config`:
  ```nix
  flake.modules.homeManager.oh-my-posh =
    { config, pkgs, ... }:
  ```

- [ ] **Step 2: Eval**

  ```bash
  nix eval .#nixosConfigurations.one-piece.config.system.build.toplevel
  ```

- [ ] **Step 3: Commit**

  ```bash
  git add modules/features/oh-my-posh.nix
  git commit -m "fix(oh-my-posh): forward config to nixpkgs-unstable import"
  ```

---

### Task 7: Fix tmux.nix non-reproducible rev

**Files:**
- Modify: `modules/features/tmux.nix`

- [ ] **Step 1: Get current commit hash for tokyo-night-tmux**

  Run this to resolve the current `master` to a commit hash:
  ```bash
  nix-prefetch-github janoamaral tokyo-night-tmux --rev master 2>/dev/null | jq -r '.rev'
  ```

  Alternatively, compute from the existing fetchFromGitHub derivation:
  ```bash
  nix eval --impure --expr 'let src = builtins.fetchGit { url = "https://github.com/janoamaral/tokyo-night-tmux"; ref = "master"; }; in src.rev'
  ```

- [ ] **Step 2: Pin the rev**

  In `modules/features/tmux.nix`, replace:
  ```nix
  rev = "master";
  sha256 = "sha256-TOS9+eOEMInAgosB3D9KhahudW2i1ZEH+IXEc0RCpU0=";
  ```
  with the actual commit hash from Step 1, keeping the same sha256 (since it's the same content):
  ```nix
  rev = "<commit-hash-from-step-1>";
  sha256 = "sha256-TOS9+eOEMInAgosB3D9KhahudW2i1ZEH+IXEc0RCpU0=";
  ```

  If the sha256 no longer matches (master has moved since last update), recompute:
  ```bash
  nix-prefetch-github janoamaral tokyo-night-tmux --rev <commit-hash>
  ```
  and use both the new rev and new sha256.

- [ ] **Step 3: Eval**

  ```bash
  nix eval .#nixosConfigurations.one-piece.config.system.build.toplevel
  ```

- [ ] **Step 4: Commit**

  ```bash
  git add modules/features/tmux.nix
  git commit -m "fix(tmux): pin tokyo-night-tmux to commit hash (was master)"
  ```

---

### Task 8: Phase 1 validation

- [ ] **Step 1: Full dry-build**

  ```bash
  nixos-rebuild dry-build --flake .#one-piece
  ```
  Expected: builds without error.

---

## PHASE 2 — Module Extractions

---

### Task 9: Extract LSP/tooling cluster into neovim.nix

**Files:**
- Modify: `modules/features/neovim.nix`
- Modify: `modules/users/rehan/packages.nix`

- [ ] **Step 1: Add LSP packages to neovim.nix**

  `modules/features/neovim.nix` — full new content:
  ```nix
  # Neovim editor - symlinks to external config
  _:

  {
    flake.modules.nixos.neovim = _: {
      programs.neovim = {
        enable = true;
        defaultEditor = true;
      };
    };

    flake.modules.homeManager.neovim =
      { config, pkgs, ... }:
      {
        xdg.configFile.nvim.source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/neovim-config";

        programs.neovim = {
          enable = true;
          defaultEditor = true;
          viAlias = true;
          vimAlias = true;
        };

        # LSPs, formatters, and build tools used by neovim plugins at runtime
        home.packages = with pkgs; [
          nil
          nodePackages_latest.vscode-json-languageserver
          yaml-language-server
          lua-language-server
          docker-language-server
          typescript
          typescript-language-server
          tailwindcss-language-server
          tree-sitter
          nodejs
          bun
          statix
          markdownlint-cli2
          addlicense
        ];
      };
  }
  ```

- [ ] **Step 2: Remove LSP packages from packages.nix**

  In `modules/users/rehan/packages.nix`, remove from `home.packages`:
  ```
  nil
  nodePackages_latest.vscode-json-languageserver
  yaml-language-server
  lua-language-server
  docker-language-server
  typescript
  typescript-language-server
  tailwindcss-language-server
  tree-sitter
  nodejs
  bun
  statix # nix linter
  markdownlint-cli2
  addlicense
  ```
  Also remove the whole `# Neovim-related (LSPs, formatters, build tools)` comment block.

  Also remove `gnumake`, `just`, `zig`, `gcc` (they move to core-packages in Task 14).

  Final `home.packages` in `packages.nix` after this task (LSPs removed, build tools removed, the rest stays):
  ```nix
  home.packages = with pkgs; [
    # Core utilities (not managed by feature modules)
    ripgrep
    nixfmt-rfc-style

    # Fonts (nerd-fonts.jetbrains-mono is in system/fonts.nix)
    noto-fonts
    nerd-fonts.iosevka
    icomoon-feather

    # Media utilities
    imv
    mediainfo
    ffmpegthumbnailer
    imagemagick

    # CLI tools
    gh
    jq
    jless
    yq

    # Git/shell tooling
    delta
    shellcheck
    shfmt

    # Nix tooling
    nix-tree

    # Encryption
    age

    # Applications
    vesktop
    bitwarden-desktop
    notesnook
    claude-code
    blender
    unityhub

    # Communication
    zoom-us
    slack
  ];
  ```

  Note: `ripgrep`, `gcc` also move to core-packages in Task 14. Leave them here for now; Task 14 removes them.

- [ ] **Step 3: Eval**

  ```bash
  nix eval .#nixosConfigurations.one-piece.config.system.build.toplevel
  ```

- [ ] **Step 4: Commit**

  ```bash
  git add modules/features/neovim.nix modules/users/rehan/packages.nix
  git commit -m "feat(neovim): absorb LSP/tooling cluster from packages.nix"
  ```

---

### Task 10: Create discord.nix

**Files:**
- Create: `modules/features/discord.nix`
- Modify: `modules/features/hyprland/default.nix`
- Modify: `modules/users/rehan/packages.nix`
- Modify: `modules/users/rehan/default.nix`

- [ ] **Step 1: Create modules/features/discord.nix**

  ```nix
  # Discord via Vesktop - better Wayland screenshare via PipeWire, Vencord pre-bundled
  _:

  {
    flake.modules.homeManager.discord =
      { config, lib, pkgs, ... }:
      let
        cfg = config.features.discord;
      in
      {
        options.features.discord.enable = lib.mkEnableOption "Discord via Vesktop";

        config = lib.mkIf cfg.enable {
          home.packages = [ pkgs.vesktop ];

          # Hyprland idle inhibit rule co-located with the app it governs
          wayland.windowManager.hyprland.settings.windowrule = [
            "idleinhibit focus, class:^(WebCord)$"
            "idleinhibit focus, class:^(discord|Discord)$"
          ];
        };
      };
  }
  ```

- [ ] **Step 2: Remove WebCord/Discord idle rules from hyprland/default.nix**

  In `modules/features/hyprland/default.nix`, remove these two lines from the `windowrule` list:
  ```nix
  "idleinhibit focus, class:^(WebCord)$"
  "idleinhibit focus, class:^(discord|Discord)$"
  ```

- [ ] **Step 3: Remove vesktop from packages.nix**

  In `modules/users/rehan/packages.nix`, remove `vesktop` from `home.packages`.

- [ ] **Step 4: Import discord in users/rehan/default.nix and enable it**

  In `modules/users/rehan/default.nix`, add to the `imports` list (under `# Desktop` section):
  ```nix
  inputs.self.modules.homeManager.discord
  ```

  Add enable option in the same file, in the inline config block after the imports (or create a separate `{ ... }` config inline module in the same user config). Since `users/rehan/default.nix` doesn't currently have a place for HM options, add a config block to the HM user config:

  In `modules/users/rehan/default.nix`, after the `imports = [ ... ];` list and before `home = { ... };`, add:
  ```nix
  features.discord.enable = true;
  ```

- [ ] **Step 5: Eval**

  ```bash
  nix eval .#nixosConfigurations.one-piece.config.system.build.toplevel
  ```

- [ ] **Step 6: Commit**

  ```bash
  git add modules/features/discord.nix modules/features/hyprland/default.nix modules/users/rehan/packages.nix modules/users/rehan/default.nix
  git commit -m "feat(discord): extract vesktop + idle rule into discord.nix"
  ```

---

### Task 11: Create communication.nix

**Files:**
- Create: `modules/features/communication.nix`
- Modify: `modules/features/hyprland/default.nix`
- Modify: `modules/users/rehan/packages.nix`
- Modify: `modules/users/rehan/default.nix`

- [ ] **Step 1: Create modules/features/communication.nix**

  ```nix
  # Communication apps - Zoom and Slack with Hyprland idle rules
  _:

  {
    flake.modules.homeManager.communication =
      { config, lib, pkgs, ... }:
      let
        cfg = config.features.communication;
      in
      {
        options.features.communication.enable = lib.mkEnableOption "communication apps (Zoom, Slack)";

        config = lib.mkIf cfg.enable {
          home.packages = with pkgs; [
            zoom-us
            slack
          ];

          # Hyprland idle inhibit rules co-located with the apps they govern
          wayland.windowManager.hyprland.settings.windowrule = [
            "idleinhibit focus, class:^(zoom|Zoom)$"
            "idleinhibit focus, class:^(Slack|slack)$"
            "idleinhibit focus, class:^(teams-for-linux|Microsoft Teams)$"
            "idleinhibit focus, title:(Google Meet)"
            "idleinhibit focus, title:(Microsoft Teams)"
            "idleinhibit focus, title:(Zoom Meeting)"
          ];
        };
      };
  }
  ```

- [ ] **Step 2: Remove communication idle rules from hyprland/default.nix**

  In `modules/features/hyprland/default.nix`, remove these lines from `windowrule`:
  ```nix
  "idleinhibit focus, class:^(zoom|Zoom)$"
  "idleinhibit focus, class:^(Slack|slack)$"
  "idleinhibit focus, class:^(teams-for-linux|Microsoft Teams)$"
  "idleinhibit focus, title:(Google Meet)"
  "idleinhibit focus, title:(Microsoft Teams)"
  "idleinhibit focus, title:(Zoom Meeting)"
  ```

- [ ] **Step 3: Remove zoom-us and slack from packages.nix**

  In `modules/users/rehan/packages.nix`, remove:
  ```nix
  # Communication
  zoom-us
  slack
  ```

- [ ] **Step 4: Import communication in users/rehan/default.nix and enable it**

  Add to `imports`:
  ```nix
  inputs.self.modules.homeManager.communication
  ```

  Add to config:
  ```nix
  features.communication.enable = true;
  ```

- [ ] **Step 5: Eval**

  ```bash
  nix eval .#nixosConfigurations.one-piece.config.system.build.toplevel
  ```

- [ ] **Step 6: Commit**

  ```bash
  git add modules/features/communication.nix modules/features/hyprland/default.nix modules/users/rehan/packages.nix modules/users/rehan/default.nix
  git commit -m "feat(communication): extract zoom/slack + idle rules into communication.nix"
  ```

---

### Task 12: Create notesnook.nix

**Files:**
- Create: `modules/features/notesnook.nix`
- Modify: `modules/users/rehan/packages.nix`
- Modify: `modules/users/rehan/default.nix`

- [ ] **Step 1: Create modules/features/notesnook.nix**

  ```nix
  # Notesnook - encrypted note-taking app
  _:

  {
    flake.modules.homeManager.notesnook =
      { config, lib, pkgs, ... }:
      let
        cfg = config.features.notesnook;
      in
      {
        options.features.notesnook.enable = lib.mkEnableOption "Notesnook note-taking app";

        config = lib.mkIf cfg.enable {
          home.packages = [ pkgs.notesnook ];
        };
      };
  }
  ```

- [ ] **Step 2: Remove notesnook from packages.nix**

- [ ] **Step 3: Import notesnook in users/rehan/default.nix and enable it**

  Add to imports:
  ```nix
  inputs.self.modules.homeManager.notesnook
  ```
  Add to config:
  ```nix
  features.notesnook.enable = true;
  ```

- [ ] **Step 4: Eval**

  ```bash
  nix eval .#nixosConfigurations.one-piece.config.system.build.toplevel
  ```

- [ ] **Step 5: Commit**

  ```bash
  git add modules/features/notesnook.nix modules/users/rehan/packages.nix modules/users/rehan/default.nix
  git commit -m "feat(notesnook): extract into notesnook.nix"
  ```

---

### Task 13: Create bitwarden.nix

**Files:**
- Create: `modules/features/bitwarden.nix`
- Modify: `modules/users/rehan/packages.nix`
- Modify: `modules/features/dank-material-shell/default.nix`
- Modify: `modules/users/rehan/default.nix`

- [ ] **Step 1: Create modules/features/bitwarden.nix**

  ```nix
  # Bitwarden password manager - desktop app and rbw CLI backend
  _:

  {
    flake.modules.homeManager.bitwarden =
      { config, lib, pkgs, ... }:
      let
        cfg = config.features.bitwarden;
      in
      {
        options.features.bitwarden.enable = lib.mkEnableOption "Bitwarden password manager";

        config = lib.mkIf cfg.enable {
          home.packages = [ pkgs.bitwarden-desktop ];

          # rbw - Bitwarden CLI backend for dankBitwarden DMS plugin
          programs.rbw = {
            enable = true;
            settings = {
              email = "mrehanabbasi@proton.me";
              pinentry = pkgs.pinentry-qt;
              base_url = "https://vaultwarden.mrehanabbasi.com";
            };
          };
        };
      };
  }
  ```

- [ ] **Step 2: Remove bitwarden-desktop from packages.nix**

  Remove `bitwarden-desktop` from `home.packages` in `modules/users/rehan/packages.nix`.

- [ ] **Step 3: Remove rbw config from dank-material-shell/default.nix**

  In `modules/features/dank-material-shell/default.nix`, remove the entire `programs.rbw` block (lines 279-287):
  ```nix
  # rbw - Bitwarden CLI backend for dankBitwarden (moved from rofi.nix)
  programs.rbw = {
    enable = true;
    settings = {
      email = "mrehanabbasi@proton.me";
      pinentry = pkgs.pinentry-qt;
      base_url = "https://vaultwarden.mrehanabbasi.com";
    };
  };
  ```

- [ ] **Step 4: Import bitwarden in users/rehan/default.nix and enable it**

  Add to imports:
  ```nix
  inputs.self.modules.homeManager.bitwarden
  ```
  Add to config:
  ```nix
  features.bitwarden.enable = true;
  ```

- [ ] **Step 5: Eval**

  ```bash
  nix eval .#nixosConfigurations.one-piece.config.system.build.toplevel
  ```

- [ ] **Step 6: Commit**

  ```bash
  git add modules/features/bitwarden.nix modules/users/rehan/packages.nix modules/features/dank-material-shell/default.nix modules/users/rehan/default.nix
  git commit -m "feat(bitwarden): extract bitwarden-desktop + rbw into bitwarden.nix"
  ```

---

### Task 14: Create unity.nix and blender.nix; move build tools to core-packages.nix

**Files:**
- Create: `modules/features/unity.nix`
- Create: `modules/features/blender.nix`
- Modify: `modules/system/core-packages.nix`
- Modify: `modules/users/rehan/packages.nix`
- Modify: `modules/users/rehan/default.nix`

- [ ] **Step 1: Create modules/features/unity.nix**

  ```nix
  # Unity Hub - game engine and editor launcher
  _:

  {
    flake.modules.homeManager.unity =
      { config, lib, pkgs, ... }:
      let
        cfg = config.features.unity;
      in
      {
        options.features.unity.enable = lib.mkEnableOption "Unity Hub game engine launcher";

        config = lib.mkIf cfg.enable {
          home.packages = [ pkgs.unityhub ];
        };
      };
  }
  ```

- [ ] **Step 2: Create modules/features/blender.nix**

  ```nix
  # Blender 3D creation suite
  # On hybrid AMD+NVIDIA: launch with `nvidia-offload blender` for GPU rendering
  _:

  {
    flake.modules.homeManager.blender =
      { config, lib, pkgs, ... }:
      let
        cfg = config.features.blender;
      in
      {
        options.features.blender.enable = lib.mkEnableOption "Blender 3D creation suite";

        config = lib.mkIf cfg.enable {
          home.packages = [ pkgs.blender ];
        };
      };
  }
  ```

- [ ] **Step 3: Add build tools to core-packages.nix**

  In `modules/system/core-packages.nix`, add to `environment.systemPackages`:
  ```nix
  # Build tools
  ripgrep
  gnumake
  just
  zig
  gcc
  ```

- [ ] **Step 4: Remove extracted packages from packages.nix**

  Remove from `modules/users/rehan/packages.nix`:
  - `ripgrep` (moved to core-packages)
  - `gcc` (moved to core-packages)
  - `gnumake`, `just`, `zig` (if still present — they should have been removed in Task 9, but were noted as still present pending this task; remove now if not already removed)
  - `blender`
  - `unityhub`

  Final `home.packages` in `packages.nix` after all Phase 2 package removals:
  ```nix
  home.packages = with pkgs; [
    # Core utilities (not managed by feature modules)
    nixfmt-rfc-style

    # Fonts (nerd-fonts.jetbrains-mono is in system/fonts.nix)
    noto-fonts
    nerd-fonts.iosevka
    icomoon-feather

    # Media utilities
    imv
    mediainfo
    ffmpegthumbnailer
    imagemagick

    # CLI tools
    gh
    jq
    jless
    yq

    # Git/shell tooling
    delta
    shellcheck
    shfmt

    # Nix tooling
    nix-tree

    # Encryption
    age

    # Applications
    claude-code
  ];
  ```

- [ ] **Step 5: Import unity and blender in users/rehan/default.nix and enable them**

  Add to imports:
  ```nix
  inputs.self.modules.homeManager.unity
  inputs.self.modules.homeManager.blender
  ```
  Add to config:
  ```nix
  features.unity.enable = true;
  features.blender.enable = true;
  ```

- [ ] **Step 6: Eval**

  ```bash
  nix eval .#nixosConfigurations.one-piece.config.system.build.toplevel
  ```

- [ ] **Step 7: Commit**

  ```bash
  git add modules/features/unity.nix modules/features/blender.nix modules/system/core-packages.nix modules/users/rehan/packages.nix modules/users/rehan/default.nix
  git commit -m "feat: extract unity, blender; move build tools to core-packages"
  ```

---

### Task 15: Phase 2 validation

- [ ] **Step 1: Full dry-build**

  ```bash
  nixos-rebuild dry-build --flake .#one-piece
  ```
  Expected: builds without error.

---

## PHASE 3 — Structural

---

### Task 16: Add mkEnableOption to theming modules

**Files:**
- Modify: `modules/theming/catppuccin.nix`

- [ ] **Step 1: Read current catppuccin.nix**

  Read `modules/theming/catppuccin.nix` to see current structure.

- [ ] **Step 2: Wrap with mkEnableOption**

  Apply the mkEnableOption pattern (see reference at top of plan). The option name is `features.catppuccin.enable`. The config moves inside `config = lib.mkIf cfg.enable { ... }`.

  The module function must add `config` and `lib` to its arguments:
  ```nix
  flake.modules.nixos.catppuccin =
    { config, lib, ... }:
    let
      cfg = config.features.catppuccin;
    in
    {
      options.features.catppuccin.enable = lib.mkEnableOption "Catppuccin theme";
      config = lib.mkIf cfg.enable {
        # existing catppuccin NixOS config
      };
    };

  flake.modules.homeManager.catppuccin =
    { config, lib, ... }:
    let
      cfg = config.features.catppuccin;
    in
    {
      options.features.catppuccin.enable = lib.mkEnableOption "Catppuccin theme";
      config = lib.mkIf cfg.enable {
        # existing catppuccin HM config
      };
    };
  ```

- [ ] **Step 3: Enable catppuccin in host config**

  In `modules/hosts/one-piece/default.nix`, add to the inline config block (the `{ ... }` at the bottom):
  ```nix
  {
    time.timeZone = "Asia/Karachi";
    i18n.defaultLocale = "en_US.UTF-8";
    system.stateVersion = "25.11";
    features.catppuccin.enable = true;
  }
  ```

  In `modules/users/rehan/default.nix`, add:
  ```nix
  features.catppuccin.enable = true;
  ```

- [ ] **Step 4: Eval**

  ```bash
  nix eval .#nixosConfigurations.one-piece.config.system.build.toplevel
  ```

- [ ] **Step 5: Commit**

  ```bash
  git add modules/theming/catppuccin.nix modules/hosts/one-piece/default.nix modules/users/rehan/default.nix
  git commit -m "feat(catppuccin): add mkEnableOption"
  ```

---

### Task 17: Add mkEnableOption to system modules

**Files:**
- Modify: `modules/system/base.nix`
- Modify: `modules/system/boot.nix`
- Modify: `modules/system/fonts.nix`
- Modify: `modules/system/networking.nix`
- Modify: `modules/system/virtualisation.nix`

- [ ] **Step 1: Read all five system modules**

  Read each file before editing:
  - `modules/system/base.nix`
  - `modules/system/boot.nix`
  - `modules/system/fonts.nix`
  - `modules/system/networking.nix`
  - `modules/system/virtualisation.nix`

- [ ] **Step 2: Apply mkEnableOption to each**

  For each module, apply the pattern using these option names:
  - `features.base.enable` — "base system configuration (Nix settings, locale, unfree)"
  - `features.boot.enable` — "boot configuration"
  - `features.fonts.enable` — "system fonts"
  - `features.networking.enable` — "system networking"
  - `features.virtualisation.enable` — "virtualisation support"

  Example — base.nix after transformation:
  ```nix
  # Base system configuration - Nix settings, locale, unfree packages
  _:

  {
    flake.modules.nixos.base =
      { config, lib, ... }:
      let
        cfg = config.features.base;
      in
      {
        options.features.base.enable = lib.mkEnableOption "base system configuration (Nix settings, locale, unfree)";

        config = lib.mkIf cfg.enable {
          nixpkgs.config.allowUnfree = true;

          nix.settings = {
            experimental-features = [
              "nix-command"
              "flakes"
            ];
            auto-optimise-store = true;
          };

          nix.gc = {
            automatic = true;
            dates = "weekly";
            options = "--delete-older-than 7d";
          };

          i18n.defaultLocale = "en_US.UTF-8";
        };
      };
  }
  ```

  Apply equivalent transformation to boot.nix, fonts.nix, networking.nix, virtualisation.nix.

- [ ] **Step 3: Enable system modules in host config**

  In `modules/hosts/one-piece/default.nix`, inline config block:
  ```nix
  {
    time.timeZone = "Asia/Karachi";
    i18n.defaultLocale = "en_US.UTF-8";
    system.stateVersion = "25.11";
    features.catppuccin.enable = true;
    features.base.enable = true;
    features.boot.enable = true;
    features.fonts.enable = true;
    features.networking.enable = true;
    features.virtualisation.enable = true;
  }
  ```

- [ ] **Step 4: Eval**

  ```bash
  nix eval .#nixosConfigurations.one-piece.config.system.build.toplevel
  ```

- [ ] **Step 5: Commit**

  ```bash
  git add modules/system/base.nix modules/system/boot.nix modules/system/fonts.nix modules/system/networking.nix modules/system/virtualisation.nix modules/hosts/one-piece/default.nix
  git commit -m "feat(system): add mkEnableOption to all system modules"
  ```

---

### Task 18: Add mkEnableOption to features modules (batch A — simple single-aspect)

This task covers simple HM-only or NixOS-only feature modules with no special concerns.

**Files to modify:**
- `modules/features/audio.nix`
- `modules/features/appimage.nix`
- `modules/features/bat.nix`
- `modules/features/brave.nix`
- `modules/features/btop.nix`
- `modules/features/core-packages.nix`
- `modules/features/core-services.nix`
- `modules/features/doppler.nix`
- `modules/features/eza.nix`
- `modules/features/fastfetch.nix`
- `modules/features/flatpak.nix`
- `modules/features/fzf.nix`
- `modules/features/gamemode.nix`
- `modules/features/gemini-cli.nix`
- `modules/features/ghostty.nix`
- `modules/features/handlr-regex.nix`
- `modules/features/kdenlive.nix`
- `modules/features/lazygit.nix`
- `modules/features/librewolf.nix`
- `modules/features/localsend.nix`
- `modules/features/mime-apps.nix`
- `modules/features/mpv.nix`
- `modules/features/obs-studio.nix`
- `modules/features/opencode.nix`
- `modules/features/pia.nix`
- `modules/features/pre-commit.nix`
- `modules/features/steam.nix`
- `modules/features/tailscale.nix`
- `modules/features/thunar.nix`
- `modules/features/voxtype.nix`
- `modules/features/vm-audio.nix`
- `modules/features/wine.nix`
- `modules/features/yazi.nix`
- `modules/features/zathura.nix`
- `modules/features/zoxide.nix`

- [ ] **Step 1: Read all files in this batch**

  Read each file listed above before editing.

- [ ] **Step 2: Apply mkEnableOption to each module**

  For each module, apply the pattern using `features.<module-name>.enable`. Derive the option name from the `flake.modules.*.foo` key name (e.g., `flake.modules.nixos.audio` → `features.audio.enable`).

  Add `config` and `lib` to each module's argument set. Move all existing config into `config = lib.mkIf cfg.enable { ... }`.

  For modules with both NixOS and HM aspects (e.g., ghostty, mpv if applicable), apply the pattern to each aspect independently using the same option name.

  Example — localsend.nix after transformation:
  ```nix
  # LocalSend for local file sharing
  _:

  {
    flake.modules.nixos.localsend =
      { config, lib, ... }:
      let
        cfg = config.features.localsend;
      in
      {
        options.features.localsend.enable = lib.mkEnableOption "LocalSend local file sharing";
        config = lib.mkIf cfg.enable {
          programs.localsend.enable = true;
        };
      };
  }
  ```

- [ ] **Step 3: Enable all batch A features in host config**

  In `modules/hosts/one-piece/default.nix` inline config block, add enable options for every NixOS-aspect module in this batch that was previously included in the modules list:
  ```nix
  features.audio.enable = true;
  features.appimage.enable = true;
  features.brave.enable = true;
  features.core-packages.enable = true;
  features.core-services.enable = true;
  features.flatpak.enable = true;
  features.gamemode.enable = true;
  features.localsend.enable = true;
  features.obs-studio.enable = true;
  features.pia.enable = true;
  features.steam.enable = true;
  features.tailscale.enable = true;
  features.thunar.enable = true;
  features.vm-audio.enable = true;
  features.wine.enable = true;
  ```

  In `modules/users/rehan/default.nix`, add enable options for every HM-aspect module in this batch:
  ```nix
  features.bat.enable = true;
  features.btop.enable = true;
  features.doppler.enable = true;
  features.eza.enable = true;
  features.fastfetch.enable = true;
  features.fzf.enable = true;
  features.gemini-cli.enable = true;
  features.ghostty.enable = true;
  features.handlr-regex.enable = true;
  features.kdenlive.enable = true;
  features.lazygit.enable = true;
  features.librewolf.enable = true;
  features.mime-apps.enable = true;
  features.mpv.enable = true;
  features.opencode.enable = true;
  features.pre-commit.enable = true;
  features.voxtype.enable = true;
  features.vm-audio.enable = true;
  features.yazi.enable = true;
  features.zathura.enable = true;
  features.zoxide.enable = true;
  ```

  Note: modules with BOTH nixos and HM aspects need enables in BOTH files. Check each module during Step 1 to identify dual-aspect modules.

- [ ] **Step 4: Eval**

  ```bash
  nix eval .#nixosConfigurations.one-piece.config.system.build.toplevel
  ```

- [ ] **Step 5: Commit**

  ```bash
  git add modules/features/ modules/hosts/one-piece/default.nix modules/users/rehan/default.nix
  git commit -m "feat(features): add mkEnableOption to batch A feature modules"
  ```

---

### Task 19: Add mkEnableOption to multi-aspect feature modules (batch B)

Multi-aspect modules (both NixOS and HM), or modules needing `inputs` (go, oh-my-posh, dank-material-shell).

**Files:**
- `modules/features/go.nix`
- `modules/features/oh-my-posh.nix`
- `modules/features/zsh.nix`
- `modules/features/neovim.nix`
- `modules/features/tmux.nix`
- `modules/features/hyprland/default.nix`
- `modules/features/kdeconnect.nix`
- `modules/features/git/default.nix`
- `modules/features/gpg/default.nix`
- `modules/features/claude/default.nix`
- `modules/features/claude-desktop.nix`
- `modules/features/dank-material-shell/default.nix`

- [ ] **Step 1: Read all files in this batch**

- [ ] **Step 2: Apply mkEnableOption to each**

  For modules using `{ inputs, ... }:` top-level, keep the outer function. Add `config` and `lib` to the inner module function:

  go.nix example (already has inputs, just add mkEnableOption):
  ```nix
  { inputs, ... }:
  {
    flake.modules.homeManager.go =
      { config, lib, pkgs, ... }:
      let
        cfg = config.features.go;
        pkgs-unstable = import inputs.nixpkgs-unstable { inherit (pkgs) system config; };
      in
      {
        options.features.go.enable = lib.mkEnableOption "Go development environment";
        config = lib.mkIf cfg.enable {
          home.packages = with pkgs-unstable; [
            go
            gopls
            gofumpt
            golangci-lint
            delve
            gotools
          ];
          home.sessionPath = [ "${config.home.homeDirectory}/go/bin" ];
        };
      };
  }
  ```

  oh-my-posh.nix — same pattern, option name `features.oh-my-posh.enable`.

  zsh.nix — has both nixos (programs.zsh.enable = true) and HM aspects:
  ```nix
  _:
  {
    flake.modules.nixos.zsh =
      { config, lib, ... }:
      let cfg = config.features.zsh; in
      {
        options.features.zsh.enable = lib.mkEnableOption "Zsh shell";
        config = lib.mkIf cfg.enable {
          programs.zsh.enable = true;
        };
      };

    flake.modules.homeManager.zsh =
      { config, lib, pkgs, ... }:
      let cfg = config.features.zsh; in
      {
        options.features.zsh.enable = lib.mkEnableOption "Zsh shell";
        config = lib.mkIf cfg.enable {
          programs.zsh = {
            # ... all existing zsh config ...
          };
        };
      };
  }
  ```

  neovim.nix — both aspects, option name `features.neovim.enable`.
  kdeconnect.nix — both aspects, option name `features.kdeconnect.enable`.
  git/default.nix — check if nixos/HM or HM-only.
  gpg/default.nix — check if nixos/HM or HM-only.
  hyprland/default.nix — both aspects, option name `features.hyprland.enable`.
  claude/default.nix — HM only, option name `features.claude.enable`.
  claude-desktop.nix — check aspect, option name `features.claude-desktop.enable`.
  dank-material-shell/default.nix — HM + NixOS (dms-greeter), option names `features.dank-material-shell.enable` and `features.dms-greeter.enable`.
  tmux.nix — HM only, option name `features.tmux.enable`.

- [ ] **Step 3: Enable batch B modules in host configs**

  In `modules/hosts/one-piece/default.nix` inline config block, add NixOS-aspect enables:
  ```nix
  features.zsh.enable = true;
  features.neovim.enable = true;
  features.hyprland.enable = true;
  features.kdeconnect.enable = true;
  features.dms-greeter.enable = true;
  ```

  In `modules/users/rehan/default.nix`, add HM-aspect enables:
  ```nix
  features.go.enable = true;
  features.oh-my-posh.enable = true;
  features.zsh.enable = true;
  features.neovim.enable = true;
  features.tmux.enable = true;
  features.hyprland.enable = true;
  features.kdeconnect.enable = true;
  features.git.enable = true;
  features.gpg.enable = true;
  features.claude.enable = true;
  features.claude-desktop.enable = true;
  features.dank-material-shell.enable = true;
  ```

- [ ] **Step 4: Eval**

  ```bash
  nix eval .#nixosConfigurations.one-piece.config.system.build.toplevel
  ```

- [ ] **Step 5: Commit**

  ```bash
  git add modules/features/ modules/hosts/one-piece/default.nix modules/users/rehan/default.nix
  git commit -m "feat(features): add mkEnableOption to batch B feature modules"
  ```

---

### Task 20: Create davinci-resolve.nix

**Files:**
- Create: `modules/features/davinci-resolve.nix`
- Modify: `modules/hosts/one-piece/default.nix`

- [ ] **Step 1: Create modules/features/davinci-resolve.nix**

  ```nix
  # DaVinci Resolve - professional video editor (free tier, unfree package)
  # On hybrid AMD+NVIDIA: launch with `nvidia-offload davinci-resolve` for GPU acceleration
  # base.nix uses allowUnfree = true which already covers this package
  _:

  {
    flake.modules.nixos.davinci-resolve =
      { config, lib, pkgs, ... }:
      let
        cfg = config.features.davinci-resolve;
      in
      {
        options.features.davinci-resolve.enable = lib.mkEnableOption "DaVinci Resolve video editor";

        config = lib.mkIf cfg.enable {
          environment.systemPackages = [ pkgs.davinci-resolve ];
        };
      };
  }
  ```

- [ ] **Step 2: Import davinci-resolve in one-piece/default.nix**

  Add to modules list in `modules/hosts/one-piece/default.nix`:
  ```nix
  inputs.self.modules.nixos.davinci-resolve
  ```

  Add to inline config block:
  ```nix
  features.davinci-resolve.enable = true;
  ```

- [ ] **Step 3: Eval**

  ```bash
  nix eval .#nixosConfigurations.one-piece.config.system.build.toplevel
  ```

- [ ] **Step 4: Commit**

  ```bash
  git add modules/features/davinci-resolve.nix modules/hosts/one-piece/default.nix
  git commit -m "feat(davinci-resolve): add DaVinci Resolve NixOS module"
  ```

---

### Task 21: Fix secrets/default.nix hardcoded path

**Files:**
- Modify: `modules/secrets/default.nix`

- [ ] **Step 1: Replace hardcoded path**

  `modules/secrets/default.nix` — full new content:
  ```nix
  # SOPS secrets management
  _:

  {
    flake.modules.nixos.sops =
      { config, ... }:
      {
        sops = {
          defaultSopsFile = ./secrets.yaml;
          defaultSopsFormat = "yaml";

          age.keyFile = "${config.users.users.rehan.home}/.config/sops/age/keys.txt";

          secrets.pia = {
            format = "yaml";
          };
        };
      };
  }
  ```

- [ ] **Step 2: Eval**

  ```bash
  nix eval .#nixosConfigurations.one-piece.config.system.build.toplevel
  ```

- [ ] **Step 3: Commit**

  ```bash
  git add modules/secrets/default.nix
  git commit -m "fix(secrets): replace hardcoded /home/rehan path with config.users.users.rehan.home"
  ```

---

### Task 22: Fix claude/default.nix path traversal

Move hook files from `.claude/hooks/` to `modules/features/claude/hooks/` so the module is self-contained.

**Files:**
- Create: `modules/features/claude/hooks/caveman-activate.js` (copy)
- Create: `modules/features/claude/hooks/caveman-mode-tracker.js` (copy)
- Create: `modules/features/claude/hooks/caveman-config.js` (copy)
- Create: `modules/features/claude/hooks/protect-files.sh` (copy)
- Create: `modules/features/claude/hooks/auto-format-nix.sh` (copy)
- Modify: `modules/features/claude/default.nix`

- [ ] **Step 1: Copy hook files**

  ```bash
  mkdir -p modules/features/claude/hooks
  cp .claude/hooks/caveman-activate.js modules/features/claude/hooks/
  cp .claude/hooks/caveman-mode-tracker.js modules/features/claude/hooks/
  cp .claude/hooks/caveman-config.js modules/features/claude/hooks/
  cp .claude/hooks/protect-files.sh modules/features/claude/hooks/
  cp .claude/hooks/auto-format-nix.sh modules/features/claude/hooks/
  ```

- [ ] **Step 2: Update path references in claude/default.nix**

  In `modules/features/claude/default.nix`, update `cavemanHooks` derivation. Change from:
  ```nix
  cp ${../../../.claude/hooks/caveman-activate.js} $out/caveman-activate.js
  cp ${../../../.claude/hooks/caveman-mode-tracker.js} $out/caveman-mode-tracker.js
  cp ${../../../.claude/hooks/caveman-config.js} $out/caveman-config.js
  ```
  to:
  ```nix
  cp ${./hooks/caveman-activate.js} $out/caveman-activate.js
  cp ${./hooks/caveman-mode-tracker.js} $out/caveman-mode-tracker.js
  cp ${./hooks/caveman-config.js} $out/caveman-config.js
  ```

  Update `home.file` sources. Change from:
  ```nix
  ".claude/hooks/protect-files.sh" = {
    source = ../../../.claude/hooks/protect-files.sh;
    executable = true;
  };
  ".claude/hooks/auto-format-nix.sh" = {
    source = ../../../.claude/hooks/auto-format-nix.sh;
    executable = true;
  };
  ```
  to:
  ```nix
  ".claude/hooks/protect-files.sh" = {
    source = ./hooks/protect-files.sh;
    executable = true;
  };
  ".claude/hooks/auto-format-nix.sh" = {
    source = ./hooks/auto-format-nix.sh;
    executable = true;
  };
  ```

- [ ] **Step 3: Verify the copies are identical to originals**

  ```bash
  diff .claude/hooks/caveman-activate.js modules/features/claude/hooks/caveman-activate.js
  diff .claude/hooks/caveman-mode-tracker.js modules/features/claude/hooks/caveman-mode-tracker.js
  diff .claude/hooks/caveman-config.js modules/features/claude/hooks/caveman-config.js
  diff .claude/hooks/protect-files.sh modules/features/claude/hooks/protect-files.sh
  diff .claude/hooks/auto-format-nix.sh modules/features/claude/hooks/auto-format-nix.sh
  ```
  Expected: all diffs empty (identical files).

- [ ] **Step 4: Eval**

  ```bash
  nix eval .#nixosConfigurations.one-piece.config.system.build.toplevel
  ```

- [ ] **Step 5: Commit**

  ```bash
  git add modules/features/claude/hooks/ modules/features/claude/default.nix
  git commit -m "fix(claude): co-locate hook files, remove ../../../ traversal"
  ```

---

### Task 23: Fix zsh.nix dead code; fix duplicate i18n.defaultLocale

**Files:**
- Modify: `modules/features/zsh.nix`
- Modify: `modules/hosts/one-piece/default.nix`

- [ ] **Step 1: Remove dead oh-my-zsh block from zsh.nix**

  In `modules/features/zsh.nix`, remove the entire `oh-my-zsh` block (lines 75-92):
  ```nix
  oh-my-zsh = {
    enable = false;
    plugins = [
      "git"
      "sudo"
      "golang"
      "command-not-found"
      "docker"
      "docker-compose"
      "eza"
      "fzf"
      "gh"
      "podman"
      "ssh"
      "tailscale"
      "zoxide"
    ];
  };
  ```

- [ ] **Step 2: Remove duplicate i18n.defaultLocale from one-piece/default.nix**

  In `modules/hosts/one-piece/default.nix`, remove `i18n.defaultLocale = "en_US.UTF-8";` from the inline config block. It is canonical in `base.nix`.

  After removing, the inline block should look like:
  ```nix
  {
    time.timeZone = "Asia/Karachi";
    system.stateVersion = "25.11";
    # features.*.enable = true; options here
  }
  ```

- [ ] **Step 3: Eval**

  ```bash
  nix eval .#nixosConfigurations.one-piece.config.system.build.toplevel
  ```

- [ ] **Step 4: Commit**

  ```bash
  git add modules/features/zsh.nix modules/hosts/one-piece/default.nix
  git commit -m "fix(zsh): remove dead oh-my-zsh block; fix(i18n): remove duplicate defaultLocale"
  ```

---

### Task 24: Fix _template/default.nix

**Files:**
- Modify: `modules/hosts/_template/default.nix`

- [ ] **Step 1: Update template with correct module names and remove raw path**

  `modules/hosts/_template/default.nix` — full new content:
  ```nix
  # Template for new hosts
  # Copy this directory and customize for your new machine
  #
  # Steps:
  # 1. Copy this directory: cp -r _template new-hostname
  # 2. Generate hardware config: nixos-generate-config --show-hardware-config > hardware.nix
  # 3. Register hardware.nix as a module: add flake.modules.nixos.new-hostname-hardware = _: { imports = [ ./hardware.nix ]; }; to a nix file in this dir
  # 4. Create gpu.nix, network.nix, etc. as needed following the same pattern
  # 5. Update the host definition below
  # 6. Remove the underscore prefix from the directory name
  #
  { inputs, ... }:
  let
    helpers = import ../../_lib { inherit inputs; };
  in
  {
    flake.nixosConfigurations.new-hostname = helpers.mkNixos {
      system = "x86_64-linux";
      modules = [
        # External flake modules
        inputs.catppuccin.nixosModules.catppuccin
        inputs.sops-nix.nixosModules.sops
        inputs.home-manager.nixosModules.home-manager

        # Base system
        inputs.self.modules.nixos.base
        inputs.self.modules.nixos.boot
        inputs.self.modules.nixos.networking
        inputs.self.modules.nixos.virtualisation
        inputs.self.modules.nixos.fonts

        # Secrets
        inputs.self.modules.nixos.sops

        # Theming
        inputs.self.modules.nixos.catppuccin

        # Services
        inputs.self.modules.nixos.audio
        inputs.self.modules.nixos.tailscale

        # Desktop
        inputs.self.modules.nixos.hyprland
        inputs.self.modules.nixos.dms-greeter
        inputs.self.modules.nixos.brave
        inputs.self.modules.nixos.core-packages
        inputs.self.modules.nixos.core-services
        inputs.self.modules.nixos.zsh
        inputs.self.modules.nixos.neovim
        inputs.self.modules.nixos.ghostty
        inputs.self.modules.nixos.gpg
        inputs.self.modules.nixos.kdeconnect

        # Host-specific (add these as modules in this directory)
        # inputs.self.modules.nixos.new-hostname-hardware
        # inputs.self.modules.nixos.new-hostname-gpu
        # inputs.self.modules.nixos.new-hostname-network

        # User
        inputs.self.modules.nixos.rehan

        # Host-specific overrides and feature enables
        {
          networking.hostName = "new-hostname";
          time.timeZone = "Asia/Karachi";
          system.stateVersion = "25.11";

          # Enable features (add/remove as needed for this host)
          features.base.enable = true;
          features.boot.enable = true;
          features.fonts.enable = true;
          features.networking.enable = true;
          features.virtualisation.enable = true;
          features.catppuccin.enable = true;
          features.audio.enable = true;
          features.tailscale.enable = true;
          features.hyprland.enable = true;
          features.dms-greeter.enable = true;
          features.brave.enable = true;
          features.core-packages.enable = true;
          features.core-services.enable = true;
          features.zsh.enable = true;
          features.neovim.enable = true;
          features.kdeconnect.enable = true;
        }
      ];
    };
  }
  ```

- [ ] **Step 2: Note — template is prefixed with `_` so importTree skips it**

  No eval needed for this file (it won't be imported by flake.nix due to the `_template` prefix). Verify the logic in `flake.nix` line 80: `if lib.hasPrefix "_" name then []` — confirms `_template` is excluded.

- [ ] **Step 3: Commit**

  ```bash
  git add modules/hosts/_template/default.nix
  git commit -m "fix(template): replace stale module names, remove raw ./hardware.nix path"
  ```

---

### Task 25: Investigate and fix DMS greeter wallpaper

**Files:**
- Modify: `modules/features/dank-material-shell/default.nix` (if fix is available)

- [ ] **Step 1: Inspect DMS greeter NixOS module options**

  ```bash
  nix eval .#nixosConfigurations.one-piece.config.programs.dank-material-shell.greeter --json 2>/dev/null | jq 'keys'
  ```

  Also check if the upstream DMS greeter module exposes a wallpaperPath option:
  ```bash
  nix eval 'inputs.dms.nixosModules.greeter' --apply 'x: builtins.attrNames x' --flake . 2>/dev/null
  ```

  Or search the DMS module source:
  ```bash
  grep -r "wallpaper" $(nix eval --raw 'inputs.dms' --flake .)/ 2>/dev/null | grep -i "greeter" | head -20
  ```

- [ ] **Step 2a: If wallpaperPath NixOS option exists**

  In `modules/features/dank-material-shell/default.nix`, in `flake.modules.nixos.dms-greeter`, add:
  ```nix
  programs.dank-material-shell.greeter.wallpaperPath = "${./background.png}";
  ```

- [ ] **Step 2b: If no NixOS wallpaperPath option exists**

  The greeter config file format must be determined from DMS source. Add the wallpaper setting as a config file entry:
  ```nix
  programs.dank-material-shell.greeter.configFiles = [
    "${./background.png}"
    (pkgs.writeText "greeter-wallpaper.json" (builtins.toJSON {
      wallpaperPath = "${./background.png}";
      wallpaperFillMode = "Fill";
    }))
  ];
  ```
  Adjust the JSON key names to match what the DMS greeter actually reads from config files.

- [ ] **Step 3: Eval**

  ```bash
  nix eval .#nixosConfigurations.one-piece.config.system.build.toplevel
  ```

- [ ] **Step 4: Commit**

  ```bash
  git add modules/features/dank-material-shell/default.nix
  git commit -m "fix(dms-greeter): set wallpaper at NixOS level so greeter service picks it up"
  ```

---

### Task 26: Phase 3 final validation and dry-build

- [ ] **Step 1: Full eval**

  ```bash
  nix eval .#nixosConfigurations.one-piece.config.system.build.toplevel
  ```

- [ ] **Step 2: Full dry-build**

  ```bash
  nixos-rebuild dry-build --flake .#one-piece
  ```

- [ ] **Step 3: Confirm all features enabled**

  ```bash
  nix eval .#nixosConfigurations.one-piece.config.features --apply builtins.attrNames --json | jq 'sort'
  ```

  Verify the list includes all expected feature names and none are missing.

---

## Self-Review Against Spec

| Spec Item | Task |
|-----------|------|
| Remove vlc, mpc, alsa-utils | Task 1 |
| webcord → vesktop | Task 1 |
| wine → wineWowPackages.stable | Task 3 |
| Declare brightnessctl, playerctl | Task 4 |
| Add delta, shellcheck, shfmt, mediainfo, ffmpegthumbnailer, imagemagick, nix-tree, age | Task 2 |
| Add delve, gotools to go.nix | Task 5 |
| Fix nixpkgs-unstable config inherit (go.nix, oh-my-posh.nix) | Tasks 5, 6 |
| Fix tmux.nix non-reproducible rev | Task 7 |
| Extend neovim.nix with LSP cluster | Task 9 |
| New discord.nix | Task 10 |
| New communication.nix | Task 11 |
| New notesnook.nix | Task 12 |
| New bitwarden.nix | Task 13 |
| New unity.nix | Task 14 |
| New blender.nix | Task 14 |
| Move ripgrep, gnumake, just, zig, gcc to core-packages | Task 14 |
| mkEnableOption on theming/ | Task 16 |
| mkEnableOption on system/ | Task 17 |
| mkEnableOption on features/ | Tasks 18, 19 |
| New davinci-resolve.nix | Task 20 |
| Fix secrets/default.nix hardcoded path | Task 21 |
| Fix claude/default.nix path traversal | Task 22 |
| Fix zsh.nix dead oh-my-zsh block | Task 23 |
| Fix duplicate i18n.defaultLocale | Task 23 |
| Fix _template/default.nix | Task 24 |
| DMS greeter wallpaper fix | Task 25 |
| dank-material-shell GTK cleanup (post-bitwarden) | Covered in Task 13 (rbw removal) — GTK theming stays in DMS per spec evaluation note |
| Host profile option-based switch | Tasks 16-19 add enable options; full restructure is ongoing as enables accumulate |
