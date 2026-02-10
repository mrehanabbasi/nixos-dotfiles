# LibreWolf browser with WebRTC and audio/video device access enabled
_:

{
  flake.modules.homeManager.librewolf =
    { pkgs, ... }:
    {
      # Set environment variables for WebRTC
      home.sessionVariables = {
        # Enable PipeWire for WebRTC screen sharing and audio
        MOZ_ENABLE_WAYLAND = "1";
        MOZ_USE_XINPUT2 = "1";
      };

      programs.librewolf = {
        enable = true;

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

        # Keep history and cookies for convenience (optional)
        "privacy.clearOnShutdown.history" = false;
        "privacy.clearOnShutdown.cookies" = false;
        "network.cookie.lifetimePolicy" = 0; # 0 = accept cookies normally

        # Enable media autoplay for conferencing (optional)
        "media.autoplay.default" = 0; # 0 = allow all

        # Disable letterboxing which can interfere with video calls
        "privacy.resistFingerprinting.letterboxing" = false;

        # Enable PipeWire for WebRTC (Firefox 110+)
        "media.webrtc.camera.allow-pipewire" = true;
        "media.webrtc.microphone.allow-pipewire" = true;
      };
    };
  };
}
