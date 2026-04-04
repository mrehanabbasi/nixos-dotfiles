# Oh-my-posh - shell prompt
# Uses nixpkgs-unstable for latest version
{ inputs, ... }:

{
  flake.modules.homeManager.oh-my-posh =
    { pkgs, ... }:
    let
      pkgs-unstable = import inputs.nixpkgs-unstable { inherit (pkgs) system; };
    in
    {
      programs.oh-my-posh = {
        enable = true;
        enableZshIntegration = true;
        package = pkgs-unstable.oh-my-posh;
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
                  options = {
                    style = "full";
                  };
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
              segments = [
                {
                  type = "executiontime";
                  style = "plain";
                  background = "transparent";
                  foreground = "yellow";
                  template = "{{ .FormattedMs }}";
                  options = {
                    threshold = 5000;
                  };
                }
              ];
            }
            {
              type = "prompt";
              alignment = "left";
              newline = true;
              segments = [
                {
                  type = "text";
                  style = "plain";
                  background = "transparent";
                  foreground_templates = [
                    "{{if gt .Code 0}}red{{end}}"
                    "{{if eq .Code 0}}magenta{{end}}"
                  ];
                  template = "❯";
                }
              ];
            }
          ];
          secondary_prompt = {
            background = "transparent";
            foreground = "p:grey";
            template = "❯❯ ";
          };
          palette = {
            grey = "#6c6c6c";
          };
        };
      };
    };
}
