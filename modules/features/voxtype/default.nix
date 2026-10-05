# VoxType push-to-talk voice-to-texk application
{ inputs, ... }:

{
  flake.modules.homeManager.voxtype =
    {
      config,
      lib,
      options,
      pkgs,
      ...
    }:
    let
      cfg = config.features.voxtype;

      # Only wire up the DMS recording overlay when the DankMaterialShell module
      # is actually in the module set, so this module stays importable on its own.
      # Same probe the dms-plugin-registry module uses.
      hasDms = options ? programs.dank-material-shell.plugins;

      # Dictation cleanup pass, run on the raw whisper transcript.
      #
      # Talks to Ollama over HTTP rather than shelling out to `ollama run`,
      # because the CLI is a TUI even when piped: it word-wraps stdout and emits
      # ESC[K (erase-to-end-of-line) escapes mid-sentence. voxtype then *types*
      # those escapes, which wipes out the line it just typed.
      #
      # think=false is load-bearing. features.ollama's Modelfile TEMPLATE
      # pre-fills an empty <think></think> block, and ollama only elides that
      # prefix when thinking is explicitly disabled - otherwise a literal
      # "<think>" plus two blank lines are prepended to every transcript.
      #
      # On any failure (ollama down, GPU still waking, timeout) fall through to
      # the raw transcript rather than typing nothing.
      postProcess = pkgs.writeShellScript "voxtype-postprocess" ''
        text="$(cat)"
        [ -z "$text" ] && exit 0

        # Styling is casual|semi-casual|semi-formal|formal, Structure is
        # prose|lists. There is no "leave formatting alone" value, so blank
        # lines in the output are always an artefact, never a model decision.
        #
        # semi-formal, not casual: "casual" is a deliberate all-lowercase style
        # (it downcases sentence starts, "I", and proper nouns), and semi-casual
        # only half-fixes that. "formal" capitalises correctly but also expands
        # contractions - "don't" becomes "do not", "can't we" becomes
        # "cannot we". semi-formal is the only value that fixes capitalisation
        # while leaving speech as spoken.
        control='[Styling: semi-formal] [Structure: prose] [Context: general]'

        out="$(
          printf '%s' "$text" \
            | ${lib.getExe pkgs.jq} -Rs --arg control "$control" \
                '{model:"s1-mini",stream:false,think:false,options:{temperature:0},prompt:($control+"\n"+.)}' \
            | ${lib.getExe pkgs.curl} -sS --max-time 14 --data-binary @- \
                http://127.0.0.1:11434/api/generate \
            | ${lib.getExe pkgs.jq} -j '(.response // "") | sub("^\\s+";"") | sub("\\s+$";"")'
        )" || out=""

        [ -n "$out" ] || out="$text"

        # Collapse every whitespace run - newlines included - to a single
        # space. [Structure: prose] means a line break is always an artefact,
        # and output.mode is "type": voxtype replays the text as keystrokes,
        # so a stray newline is a literal Enter that submits the chat box or
        # search bar mid-dictation. Applied to the fallback too, since a raw
        # whisper transcript can carry segment breaks of its own.
        # Trimmed with parameter expansion rather than a sed pass, because sed
        # terminates its last line with a newline - reintroducing exactly what
        # this is here to remove.
        out="$(printf '%s' "$out" | ${pkgs.coreutils}/bin/tr -s '[:space:]' ' ')"
        out="''${out# }"
        out="''${out% }"
        printf '%s' "$out"
      '';

      # Registry plugin, patched down to roughly half its upstream size: the
      # stock pill is scaled for a 48px bar and dominates the screen next to a
      # 2px-gap layout. Transcribing-phase visibility is upstream as of 1.3.0.
      overlayPlugin = pkgs.applyPatches {
        name = "dms-voxtype-activity-overlay-patched";
        src =
          (import "${inputs.dms-plugin-registry}/nix/default.nix" { inherit pkgs; }).voxtypeActivityOverlay;
        patches = [ ./overlay-compact-pill.patch ];
      };
      # Bottom-centre pill: live mic waveform while recording, spinner after.
      overlayConfig = {
        programs.dank-material-shell.plugins.voxtypeActivityOverlay = {
          enable = true;
          src = lib.mkForce overlayPlugin;
          settings = {
            visualizerMode = "bars";
            visualizerSensitivity = 180;
            showCancelButton = false;
            # The transcript bubble needs a capture hook in voxtype's
            # post_process, which is already used for the s1-mini pass.
            showTranscriptText = false;
          };
        };

        # Cava drives the bars off the default capture device. The plugin
        # hardcodes this path; source the ini from the plugin so it cannot drift.
        xdg.configFile."cava/dms-voxtype-activity-overlay.ini".source =
          "${overlayPlugin}/config/cava/dms-voxtype-activity-overlay.ini";

        home.packages = [ pkgs.cava ];
      };
    in
    {
      options.features.voxtype.enable = lib.mkEnableOption "VoxType push-to-talk voice-to-text";
      config = lib.mkIf cfg.enable (
        lib.mkMerge [
          (lib.optionalAttrs hasDms overlayConfig)
          {
            # The daemon reads config.toml once at startup and never re-reads it.
            # config.toml is an xdg.configFile, so changing a setting here leaves
            # voxtype.service byte-identical and home-manager's startServices sees
            # nothing to restart - the running daemon then keeps serving the old
            # settings indefinitely. Fold the config's store path into the unit so
            # a settings change is a unit change, and the restart happens.
            systemd.user.services.voxtype.Unit.X-Restart-Triggers = [
              "${config.xdg.configFile."voxtype/config.toml".source}"
            ];

            programs.voxtype = {
              enable = true;

              # Whisper rather than Parakeet, for accent robustness. Parakeet TDT is
              # trained on 25 *European* languages, so South-Asian-accented English is
              # out of distribution for it and no config setting can repair that.
              # Whisper saw 680k hours of diverse accented/L2 English. Whisper also
              # happens to be the only engine with a cached GPU build (vulkan), so
              # this avoids the onnx-cuda source build entirely.
              engine = "whisper";

              # Vulkan backend - vendor-neutral API that AMD, Intel and the
              # NVIDIA proprietary driver all implement, so one package covers
              # every GPU. In the binary cache, unlike CUDA. mkDefault so a
              # host with no GPU (or one needing a different backend) can swap
              # it without mkForce.
              package = lib.mkDefault inputs.voxtype.packages.${pkgs.stdenv.hostPlatform.system}.vulkan;

              # Fetched declaratively by the voxtype HM module (whisper models only),
              # so there is no manual `voxtype setup model` step.
              # Full large-v3 over large-v3-turbo deliberately: turbo distils the
              # decoder from 32 layers to 4, and the decoder is what disambiguates
              # acoustically unclear audio from context - exactly what accented
              # speech depends on. Costs ~3.1 GB of VRAM, so mkDefault: a host
              # with a smaller GPU drops to large-v3-turbo or a -q5 quant.
              model.name = lib.mkDefault "large-v3";

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

                  # ~10% faster inference, ~75% less VRAM, on the Vulkan backend.
                  # No accuracy tradeoff - unlike context_window_optimization
                  # above, this isn't linked to the phrase-repetition bug.
                  flash_attention = true;
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
                  # The text appearing *is* the completion signal, and the DMS
                  # overlay pill already covers the recording/transcribing phases.
                  # A desktop notification on top of that is pure noise.
                  notification.on_transcription = false;
                  post_process = {
                    # superwhisper/s1-mini via Ollama (see features.ollama): purpose-built
                    # for exactly this - strips fillers, resolves self-corrections/false
                    # starts to what was actually meant, fixes punctuation. It is NOT an
                    # instruct model - it's steered with a control line, not a prompt.
                    # Also supplies the punctuation whisper itself does not emit.
                    command = "${postProcess}";
                    # Comfortably above the script's own 14s curl deadline, so the
                    # raw-transcript fallback gets a chance to run.
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
          }
        ]
      );
    };
}
