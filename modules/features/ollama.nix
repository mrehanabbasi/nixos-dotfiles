# Ollama - local LLM server, used here for VoxType dictation cleanup
# (removing filler words / self-corrections from rambling dictation).
#
# GPU accel via Vulkan, not CUDA/ROCm. Vulkan is vendor-neutral - AMD, Intel
# and the NVIDIA proprietary driver all implement it - so one package covers
# every GPU, and ollama-vulkan is in the binary cache (~44 MiB fetch, zero
# builds) whereas ollama-cuda is unfree and must compile locally for hours.
# Overridable: services.ollama.package is set with mkDefault.
_:

{
  flake.modules.nixos.ollama =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.features.ollama;

      # superwhisper/s1-mini: purpose-built ASR-transcript cleanup model
      # (fillers, false starts/self-corrections, punctuation). NOT a chat
      # model - steered via a control line, thinking mode must stay off.
      # https://huggingface.co/superwhisper/s1-mini-GGUF
      s1MiniGguf = pkgs.fetchurl {
        url = "https://huggingface.co/superwhisper/s1-mini-GGUF/resolve/main/s1-mini-q4_k_m.gguf";
        hash = "sha256-O0Hr4lAsvQPoEdXRawIvWrVR7aWNYll9FS+JU1ADxjQ=";
      };

      s1MiniModelfile = pkgs.writeText "s1-mini.Modelfile" ''
        FROM ${s1MiniGguf}

        SYSTEM """You are a text normalizer for speech-to-text transcripts. The input begins with a control line specifying the styling, structure, and context settings; clean the transcript to match those settings and output only the cleaned text."""

        TEMPLATE """<|im_start|>system
        {{ .System }}<|im_end|>
        <|im_start|>user
        {{ .Prompt }}<|im_end|>
        <|im_start|>assistant
        <think>

        </think>

        """

        PARAMETER temperature 0
        PARAMETER num_ctx 1024
      '';
    in
    {
      options.features.ollama.enable = lib.mkEnableOption "Ollama local LLM server";

      config = lib.mkIf cfg.enable {
        services.ollama = {
          enable = true;
          package = lib.mkDefault pkgs.ollama-vulkan;

          environmentVariables = {
            # Long keep-alive because a GPU that runtime-suspends while idle
            # (anything with finegrained power management) makes the reload
            # after an unload cost GPU wake + model load - a couple of seconds
            # on the first dictation after a gap, not the sub-second the
            # default assumes. Keeping the model warm is cheaper; harmless on
            # hosts whose GPU never powers down.
            OLLAMA_KEEP_ALIVE = lib.mkDefault "10m";

            # Flash attention: faster attention kernel, no accuracy cost.
            OLLAMA_FLASH_ATTENTION = "1";
          };
        };

        systemd.services.ollama-s1-mini = {
          description = "Register s1-mini dictation-cleanup model with Ollama";
          wantedBy = [ "multi-user.target" ];
          after = [ "ollama.service" ];
          requires = [ "ollama.service" ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            User = config.services.ollama.user;
            Group = config.services.ollama.group;
            Environment = [
              "OLLAMA_HOST=127.0.0.1:${toString config.services.ollama.port}"
              "HOME=${config.services.ollama.home}"
            ];
            ExecStart = "${lib.getExe config.services.ollama.package} create s1-mini -f ${s1MiniModelfile}";
          };
        };
      };
    };
}
