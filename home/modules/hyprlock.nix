{ config, ... }:

{
  catppuccin.hyprlock = {
    enable = true;
    useDefaultConfig = false;
  };

  programs.hyprlock = {
    enable = true;
    sourceFirst = true;
    settings = {
      "$font" = "JetBrainsMono Nerd Font";

      general = {
        hide_cursor = true;
      };

      background = [
        {
          monitor = "";
          path = "${../../wallpapers/light.png}";
          blur_passes = 0;
          color = "$base";
        }
      ];

      label = [
        # Layout
        {
          monitor = "";
          text = "";
          color = "$text";
          font_size = 25;
          font_family = "$font";
          position = "30, -30";
          halign = "left";
          valign = "top";
        }
        # Time
        {
          monitor = "";
          text = "$TIME12";
          color = "$text";
          font_size = 50;
          font_family = "$font";
          position = "40, -30";
          halign = "left";
          valign = "top";
        }
        # Date
        {
          monitor = "";
          text = "";
          color = "$text";
          font_size = 25;
          font_family = "$font";
          position = "0, 0";
          halign = "center";
          valign = "bottom";
        }
        # Fingerprint
        {
          monitor = "";
          text = "$FPRINTPROMPT";
          font_size = 14;
          font_family = "$font";
          position = "0, -107";
          halign = "center";
          valign = "center";
        }
      ];

      image = [
        {
          monitor = "";
          path = "${config.home.homeDirectory}/.face";
          size = 100;
          border_color = "$accent";
          position = "0, 75";
          halign = "center";
          valign = "center";
        }
      ];

      input-field = [
        {
          monitor = "";
          size = "300, 60";
          outline_thickness = 4;
          dots_size = 0.2;
          dots_spacing = 0.2;
          dots_center = true;
          outer_color = "$accent";
          inner_color = "$surface0";
          font_color = "$text";
          fade_on_empty = false;
          placeholder_text = "<span foreground=\"##$textAlpha\"><i>󰌾 Logged in as </i><span foreground=\"##$accentAlpha\">$USER</span></span>";
          hide_input = false;
          check_color = "$accent";
          fail_color = "$red";
          fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
          capslock_color = "$yellow";
          position = "0, -47";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };
}
