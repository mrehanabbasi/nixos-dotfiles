# VoxType push-to-talk voice-to-texk application
{ inputs, ... }:

{
  flake.modules.homeManager.voxtype =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.features.voxtype;
    in
    {
      options.features.voxtype.enable = lib.mkEnableOption "VoxType push-to-talk voice-to-text";
      config = lib.mkIf cfg.enable {
        programs.voxtype = {
          enable = true;

          # Whisper rather than Parakeet, for accent robustness. Parakeet TDT is
          # trained on 25 *European* languages, so South-Asian-accented English is
          # out of distribution for it and no config setting can repair that.
          # Whisper saw 680k hours of diverse accented/L2 English. Whisper also
          # happens to be the only engine with a cached GPU build (vulkan), so
          # this avoids the onnx-cuda source build entirely.
          engine = "whisper";

          # Vulkan backend - vendor-neutral API that NVIDIA's driver implements,
          # so this runs on the RTX 4050. In the binary cache, unlike CUDA.
          package = inputs.voxtype.packages.${pkgs.stdenv.hostPlatform.system}.vulkan;

          # Fetched declaratively by the voxtype HM module (whisper models only),
          # so there is no manual `voxtype setup model` step.
          # Full large-v3 over large-v3-turbo deliberately: turbo distils the
          # decoder from 32 layers to 4, and the decoder is what disambiguates
          # acoustically unclear audio from context - exactly what accented
          # speech depends on. ~3.1 GB, fits the 4050's 6 GB fine.
          model.name = "large-v3";

          service.enable = true;
          settings = {
            # Using Hyprland keybinding instead
            # hotkey = {
            #   enabled = true;
            #   key = "INSERT";
            # };
            whisper = {
              language = "en";
              # large-v3 is the model most prone to whisper's phrase-repetition
              # loop ("increase the limit increase the limit ..."), and context
              # window optimisation is the documented trigger. Keep it off.
              context_window_optimization = false;
            };

            # Whisper hallucinates on silence ("Thank you.", "Thanks for
            # watching."). VAD is a whole-recording gate - it drops clips with no
            # speech at all, so holding the key and saying nothing yields nothing.
            # It does NOT strip pauses inside an utterance; the s1-mini pass below
            # is the backstop for artefacts that survive.
            vad = {
              enabled = true;
              # Energy VAD needs no model download; whisper/Silero backend would
              # require an imperative `voxtype setup vad`.
              backend = "energy";
              # Below the 0.5 default so quieter or accented speech is not
              # rejected as silence.
              threshold = 0.3;
            };

            output = {
              mode = "type";
              fallback_to_clipboard = true;
              post_process = {
                # superwhisper/s1-mini via Ollama (see features.ollama): purpose-built
                # for exactly this - strips fillers, resolves self-corrections/false
                # starts to what was actually meant, fixes punctuation. It is NOT an
                # instruct model - it's steered with a control line, not a prompt.
                # Also supplies the punctuation whisper itself does not emit.
                command = ''
                  sh -c 'text="$(cat)"; prompt="[Styling: casual] [Structure: prose] [Context: general]
                  $text"; exec ollama run s1-mini "$prompt"'
                '';
                timeout_ms = 15000;
              };
            };
            text = {
              spoken_punctuation = true;
              replacements = {
                "vox type" = "voxtype";
              };
            };
            state_file = "auto";
          };
        };
      };
    };
}
