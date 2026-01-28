# Oh-my-posh - shell prompt
{ ... }:

{
  flake.modules.homeManager.oh-my-posh = { pkgs, ... }:
    let
      # Get latest version of oh-my-posh since nixpkgs' version lags behind
      oh-my-posh = pkgs.stdenv.mkDerivation {
        pname = "oh-my-posh";
        version = "v28.3.1";

        src = pkgs.fetchurl {
          url = "https://github.com/JanDeDobbeleer/oh-my-posh/releases/download/v28.3.1/posh-linux-amd64";
          sha256 = "0gjvawgg6sg3rz3vmq90bsgilprndfa8alihg5cvgj3ra5gkpcgg";
        };

        dontUnpack = true;

        installPhase = ''
          mkdir -p $out/bin
          cp $src $out/bin/oh-my-posh
          chmod +x $out/bin/oh-my-posh
        '';

        meta = { mainProgram = "oh-my-posh"; };
      };
    in
    {
      programs.oh-my-posh = {
        enable = true;
        enableZshIntegration = true;
        package = oh-my-posh;
        settings = {
          version = 4;
          final_space = true;
          console_title_template = "{{ .Shell }} in {{ .Folder }}";
          blocks = [
            {
              type = "prompt";
              alignment = "left";
              newline = true;
              segments = [
                {
                  type = "path";
                  style = "plain";
                  background = "transparent";
                  foreground = "blue";
                  template = "{{ .Path }}";
                  options = { style = "full"; };
                }
                {
                  type = "git";
                  style = "plain";
                  background = "transparent";
                  foreground = "p:grey";
                  template = " {{ .HEAD }}{{ if .Merge }}|MERGING{{ end }}{{ if .Rebase }}|REBASING{{ end }}{{ if .CherryPick }}|CHERRYPICKING{{ end }}{{ if .Revert }}|REVERTING{{ end }}{{ if or .Working.Modified .Working.Deleted }}*{{ end }}{{ if or .Staging.Changed .Staging.Modified }}+{{ end }}{{ if gt .Working.Untracked 0 }}%{{ end }} <cyan>{{ if gt .Behind 0 }}⇣{{ end }}{{ if gt .Ahead 0 }}⇡{{ end }}</>";
                  options = {
                    branch_icon = "";
                    commit_icon = "@";
                    fetch_status = true;
                  };
                }
              ];
            }
            {
              type = "rprompt";
              alignment = "right";
              overflow = "hidden";
              segments = [{
                type = "executiontime";
                style = "plain";
                background = "transparent";
                foreground = "yellow";
                template = "{{ .FormattedMs }}";
                options = { threshold = 5000; };
              }];
            }
            {
              type = "prompt";
              alignment = "left";
              newline = true;
              segments = [{
                type = "text";
                style = "plain";
                background = "transparent";
                foreground_templates = [
                  "{{if gt .Code 0}}red{{end}}"
                  "{{if eq .Code 0}}magenta{{end}}"
                ];
                template = "❯";
              }];
            }
          ];
          secondary_prompt = {
            background = "transparent";
            foreground = "p:grey";
            template = "❯❯ ";
          };
          palette = { grey = "#6c6c6c"; };
        };
      };
    };
}
