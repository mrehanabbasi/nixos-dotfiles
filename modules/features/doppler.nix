# Doppler - secrets manager CLI with per-directory shell integration
_:

{
  flake.modules.homeManager.doppler =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.doppler ];

      programs.zsh.initContent = ''
        # Doppler per-directory secret injection
        typeset -a _doppler_loaded_vars
        _doppler_loaded_vars=()
        _doppler_prev_project=""

        _doppler_load() {
          local current_project
          current_project=$(doppler configure get project --plain 2>/dev/null)

          if [[ -z "$current_project" ]]; then
            # Not a doppler-enabled directory; unload previously loaded vars
            if [[ ''${#_doppler_loaded_vars[@]} -gt 0 ]]; then
              for _var in "''${_doppler_loaded_vars[@]}"; do
                unset "$_var"
              done
              _doppler_loaded_vars=()
              _doppler_prev_project=""
            fi
            return
          fi

          # Still in the same project tree; skip reload
          if [[ "$current_project" == "$_doppler_prev_project" ]]; then
            return
          fi

          # Unload vars from any previous project before loading new ones
          if [[ ''${#_doppler_loaded_vars[@]} -gt 0 ]]; then
            for _var in "''${_doppler_loaded_vars[@]}"; do
              unset "$_var"
            done
            _doppler_loaded_vars=()
          fi

          _doppler_prev_project="$current_project"

          local secrets_output
          secrets_output=$(doppler secrets download --no-file --format env 2>/dev/null)
          if [[ -z "$secrets_output" ]]; then
            return
          fi

          while IFS= read -r line; do
            # Lines are KEY="VALUE" format
            if [[ "$line" =~ ^([A-Za-z_][A-Za-z0-9_]*)= ]]; then
              local var_name="''${match[1]}"
              eval "export $line"
              _doppler_loaded_vars+=("$var_name")
            fi
          done <<< "$secrets_output"
        }

        autoload -Uz add-zsh-hook
        add-zsh-hook chpwd _doppler_load
        # Load on shell startup if already in a doppler-enabled directory
        _doppler_load
      '';
    };
}
