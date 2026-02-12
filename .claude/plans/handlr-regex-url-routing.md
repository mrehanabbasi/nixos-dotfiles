# Plan: URL Routing with handlr-regex

Route YouTube, Google, Facebook, Instagram, and TikTok links to LibreWolf while all other URLs open in Brave.

## Overview

**handlr-regex** intercepts all URL opens via `x-scheme-handler/http(s)`, matches URLs against regex patterns, and routes to the appropriate browser. Non-matching URLs fall back to Brave.

## Files to Create/Modify

### 1. Create: `modules/programs/cli/handlr-regex.nix`

```nix
# handlr-regex - URL routing based on regex patterns
# Routes YouTube, Google, Facebook, Instagram, TikTok to LibreWolf
# All other URLs go to Brave (default browser)
_:

{
  flake.modules.homeManager.handlr-regex =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.handlr-regex ];

      # Desktop entry for handlr (required for MIME association)
      xdg.desktopEntries.handlr = {
        name = "Handlr URL Router";
        genericName = "URL Handler";
        exec = "handlr open %u";
        terminal = false;
        mimeType = [
          "x-scheme-handler/http"
          "x-scheme-handler/https"
        ];
        categories = [ "Network" "WebBrowser" ];
        comment = "Routes URLs to browsers based on regex patterns";
        noDisplay = true;
      };

      # handlr configuration
      xdg.configFile."handlr/handlr.toml".text = ''
        enable_selector = false
        default_browser = "brave-browser.desktop"

        # YouTube (main site, short URLs, music)
        [[handlers]]
        exec = "librewolf %u"
        terminal = false
        regexes = [
          'https?://(www\.)?youtube\.com',
          'https?://youtu\.be',
          'https?://music\.youtube\.com',
        ]

        # Google (all TLDs)
        [[handlers]]
        exec = "librewolf %u"
        terminal = false
        regexes = ['https?://(www\.)?google\.[a-z.]+']

        # Facebook (main site + short domains)
        [[handlers]]
        exec = "librewolf %u"
        terminal = false
        regexes = ['https?://(www\.)?(facebook\.com|fb\.com|fb\.watch)']

        # Instagram
        [[handlers]]
        exec = "librewolf %u"
        terminal = false
        regexes = ['https?://(www\.)?instagram\.com']

        # TikTok (main + short URLs)
        [[handlers]]
        exec = "librewolf %u"
        terminal = false
        regexes = ['https?://(www\.)?(tiktok\.com|vm\.tiktok\.com)']
      '';
    };
}
```

### 2. Modify: `modules/programs/mime-apps.nix`

Change lines 20-21 from Brave to handlr:

```nix
"x-scheme-handler/http" = [ "handlr.desktop" ];
"x-scheme-handler/https" = [ "handlr.desktop" ];
```

### 3. Modify: `modules/users/rehan/default.nix`

Add after line 62 (after `oh-my-posh`):

```nix
inputs.self.modules.homeManager.handlr-regex
```

## URL Patterns

| Site | Regex Pattern |
|------|---------------|
| YouTube | `https?://(www\.)?youtube\.com` |
| YouTube Short | `https?://youtu\.be` |
| YouTube Music | `https?://music\.youtube\.com` |
| Google | `https?://(www\.)?google\.[a-z.]+` |
| Facebook | `https?://(www\.)?(facebook\.com\|fb\.com\|fb\.watch)` |
| Instagram | `https?://(www\.)?instagram\.com` |
| TikTok | `https?://(www\.)?(tiktok\.com\|vm\.tiktok\.com)` |

## Verification

After rebuilding:

```bash
# Test LibreWolf routing (should open in LibreWolf)
handlr open "https://www.youtube.com/watch?v=test"
handlr open "https://www.google.com/search?q=test"
handlr open "https://www.facebook.com"
handlr open "https://www.instagram.com"
handlr open "https://www.tiktok.com"

# Test Brave fallback (should open in Brave)
handlr open "https://github.com"
handlr open "https://nixos.org"

# Verify MIME association
xdg-mime query default x-scheme-handler/https
# Expected output: handlr.desktop

# Test from terminal
xdg-open "https://youtube.com"  # Should open LibreWolf
xdg-open "https://github.com"   # Should open Brave
```

## Rollback

If issues occur, revert mime-apps.nix changes:
```nix
"x-scheme-handler/http" = [ "brave-browser.desktop" ];
"x-scheme-handler/https" = [ "brave-browser.desktop" ];
```

Remove the handlr-regex import from `modules/users/rehan/default.nix`.
