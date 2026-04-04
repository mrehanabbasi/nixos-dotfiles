# LibreWolf browser with WebRTC and audio/video device access enabled
# Home Manager only - programs.librewolf.enable installs the package
_:

{
  flake.modules.homeManager.librewolf = _: {
    # Set environment variables for WebRTC
    home.sessionVariables = {
      # Enable PipeWire for WebRTC screen sharing and audio
      MOZ_ENABLE_WAYLAND = "1";
      MOZ_USE_XINPUT2 = "1";
    };

    programs.librewolf = {
      enable = true;

      policies = {
        # Cookie exceptions - these sites keep cookies on shutdown
        Cookies = {
          Allow = [
            "https://facebook.com"
            "http://facebook.com"
            "https://youtube.com"
            "http://youtube.com"
            "https://google.com"
            "http://google.com"
            "https://instagram.com"
            "http://instagram.com"
          ];
        };
      };

      # Configure settings for WebRTC and media device access
      settings = {
        # Enable WebRTC for video/audio calls
        "media.navigator.enabled" = true;
        "media.navigator.permission.disabled" = false;
        "media.peerconnection.enabled" = true;

        # Allow device enumeration for audio/video devices
        "media.navigator.streams.fake" = false;
        "media.setsinkid.enabled" = true; # Allow apps to select specific audio output devices

        # Enable WebGL (required for some web conferencing features)
        "webgl.disabled" = false;

        # Reduce fingerprinting resistance to allow device access
        # Note: This is necessary for Google Meet to enumerate devices
        "privacy.resistFingerprinting" = false;

        # Allow persistent permissions for trusted sites
        "permissions.default.microphone" = 0; # 0 = always ask
        "permissions.default.camera" = 0; # 0 = always ask

        # Keep history on shutdown but clear cookies (with exceptions)
        "privacy.clearOnShutdown.history" = false;
        "privacy.clearOnShutdown.cookies" = true;
        "network.cookie.lifetimePolicy" = 0; # 0 = accept cookies normally

        # Enable media autoplay for conferencing (optional)
        "media.autoplay.default" = 0; # 0 = allow all

        # Disable letterboxing which can interfere with video calls
        "privacy.resistFingerprinting.letterboxing" = false;

        # Enable PipeWire for WebRTC (Firefox 110+)
        "media.webrtc.camera.allow-pipewire" = true;
        "media.webrtc.microphone.allow-pipewire" = true;

        # Block cookie banners
        "cookiebanners.service.mode" = 2;
        "cookiebanners.service.mode.privateBrowsing" = 2;
      };
    };
  };
}
