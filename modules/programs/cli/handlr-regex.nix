# handlr-regex - URL routing based on regex patterns
# Routes big tech URLs to LibreWolf, all other URLs go to Brave
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
        categories = [
          "Network"
          "WebBrowser"
        ];
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

        # Google services (Gmail, Drive, Docs, Play, Blogger)
        [[handlers]]
        exec = "librewolf %u"
        terminal = false
        regexes = [
          'https?://(www\.)?gmail\.com',
          'https?://drive\.google\.com',
          'https?://docs\.google\.com',
          'https?://sheets\.google\.com',
          'https?://play\.google\.com',
          'https?://(www\.)?blogger\.com',
          'https?://[a-z0-9-]+\.blogspot\.com',
        ]

        # Meta (Messenger, WhatsApp, Threads)
        [[handlers]]
        exec = "librewolf %u"
        terminal = false
        regexes = [
          'https?://(www\.)?messenger\.com',
          'https?://(www\.|web\.)?whatsapp\.com',
          'https?://(www\.)?threads\.net',
        ]

        # Microsoft (Bing, Outlook, Office)
        [[handlers]]
        exec = "librewolf %u"
        terminal = false
        regexes = [
          'https?://(www\.)?bing\.com',
          'https?://(www\.)?microsoft\.com',
          'https?://(www\.)?live\.com',
          'https?://(www\.)?outlook\.com',
          'https?://(www\.)?office\.com',
          'https?://(www\.)?office365\.com',
        ]

        # Twitter/X
        [[handlers]]
        exec = "librewolf %u"
        terminal = false
        regexes = [
          'https?://(www\.)?twitter\.com',
          'https?://(www\.)?x\.com',
          'https?://t\.co',
        ]

        # Other trackers (Snapchat, Pinterest)
        [[handlers]]
        exec = "librewolf %u"
        terminal = false
        regexes = [
          'https?://(www\.)?snapchat\.com',
          'https?://(www\.)?pinterest\.com',
        ]
      '';
    };
}
