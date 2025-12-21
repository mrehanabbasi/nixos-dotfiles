{ ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;

    settings = {
      # Monitors
      monitor = ",highres,auto,1";

      # Programs
      "$terminal" = "ghostty";
      "$fileManager" = "$terminal -e yazi";
      "$menu" = "$XDG_CONFIG_HOME/rofi/launchers/type-1/launcher.sh &";
      "$webBrowser" = "brave --allowlisted-extension-id=clngdbkpkpeebahjckkjfobafhncgmne";
      "$cursorTheme" = "Catppuccin Mocha Blue";
      "$cursorSize" = "24";

      # Autostart
      exec-once = [
        "hyprpanel & hyprpaper & hypridle"
        "hyprctl setcursor $cursorTheme $cursorSize"
        "kdeconnectd & kdeconnect-indicator &"
      ];

      # Environment variables
      env = [
        "XCURSOR_SIZE,$cursorTheme"
      ];

      # General
      general = {
        gaps_in = 2;
        gaps_out = 5;
        border_size = 1;
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
        resize_on_border = false;
        allow_tearing = false;
        layout = "dwindle";
      };

      # Decoration
      decoration = {
        rounding = 4;
        rounding_power = 2;
        active_opacity = 1.0;
        inactive_opacity = 0.95;

        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
          color = "rgba(1a1a1aee)";
        };

        blur = {
          enabled = true;
          size = 3;
          passes = 1;
          vibrancy = 0.1696;
        };
      };

      # Animations
      animations = {
        enabled = "yes, please :)";

        bezier = [
          "easeOutQuint, 0.23, 1, 0.32, 1"
          "easeInOutCubic, 0.65, 0.05, 0.36, 1"
          "linear, 0, 0, 1, 1"
          "almostLinear, 0.5, 0.5, 0.75, 1"
          "quick, 0.15, 0, 0.1, 1"
        ];

        animation = [
          "global, 1, 10, default"
          "border, 1, 5.39, easeOutQuint"
          "windows, 1, 4.79, easeOutQuint"
          "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
          "windowsOut, 1, 1.49, linear, popin 87%"
          "fadeIn, 1, 1.73, almostLinear"
          "fadeOut, 1, 1.46, almostLinear"
          "fade, 1, 3.03, quick"
          "layers, 1, 3.81, easeOutQuint"
          "layersIn, 1, 4, easeOutQuint, fade"
          "layersOut, 1, 1.5, linear, fade"
          "fadeLayersIn, 1, 1.79, almostLinear"
          "fadeLayersOut, 1, 1.39, almostLinear"
          "workspaces, 1, 1.94, almostLinear, fade"
          "workspacesIn, 1, 1.21, almostLinear, fade"
          "workspacesOut, 1, 1.94, almostLinear, fade"
          "zoomFactor, 1, 7, quick"
        ];
      };

      # Layouts
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      master = {
        new_status = "master";
      };

      # Misc
      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo = false;
      };

      # Input
      input = {
        kb_layout = "us";
        follow_mouse = 1;
        sensitivity = 0;

        touchpad = {
          natural_scroll = true;
        };
      };

      # Gestures
      gesture = "3, horizontal, workspace";

      # Per-device config
      device = {
        name = "epic-mouse-v1";
        sensitivity = -0.5;
      };

      # Main modifier
      "$mainMod" = "SUPER";

      # Keybindings
      bind = [
        # Application shortcuts
        "$mainMod, RETURN, exec, $terminal"
        "$mainMod, Q, killactive,"
        "$mainMod, M, exit,"
        "$mainMod, E, exec, $fileManager"
        "$mainMod SHIFT, E, exec, dolphin"
        "$mainMod, V, togglefloating,"
        "$mainMod, Space, exec, $menu"
        "$mainMod, Print, exec, hyprshot -m region"
        "$mainMod SHIFT, Print, exec, hyprshot -m output"
        "$mainMod SHIFT, P, exec, hyprpicker"
        "$mainMod, P, pseudo,"
        "$mainMod, S, togglesplit,"
        "$mainMod, B, exec, $webBrowser"
        "$mainMod, T, exec, $terminal --title='btop' -e btop"
        "$mainMod, SEMICOLON, exec, hyprlock"
        "$mainMod, N, exec, hyprpanel toggleWindow notificationsmenu"
        "$mainMod SHIFT, N, exec, hyprpanel clearNotifications"

        # Move focus with vim keys
        "$mainMod, H, movefocus, l"
        "$mainMod, L, movefocus, r"
        "$mainMod, K, movefocus, u"
        "$mainMod, J, movefocus, d"

        # Switch workspaces
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"

        # Move window to workspace
        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"

        # Swap windows with vim keys
        "$mainMod SHIFT, H, swapwindow, l"
        "$mainMod SHIFT, L, swapwindow, r"
        "$mainMod SHIFT, K, swapwindow, u"
        "$mainMod SHIFT, J, swapwindow, d"

        # Special workspace (scratchpad)
        "$mainMod, S, togglespecialworkspace, magic"
        "$mainMod SHIFT, S, movetoworkspace, special:magic"

        # Scroll through workspaces
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"

        # Resize windows
        "$mainMod SHIFT, UP, resizeactive, 0 -20"
        "$mainMod SHIFT, DOWN, resizeactive, 0 20"
        "$mainMod SHIFT, LEFT, resizeactive, -20 0"
        "$mainMod SHIFT, RIGHT, resizeactive, 20 0"

        # Move workspace to monitor
        "$mainMod, Tab, movecurrentworkspacetomonitor, +1"
        "$mainMod SHIFT, Tab, movecurrentworkspacetomonitor, -1"
      ];

      # Mouse bindings
      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      # Lid switch
      bindl = [
        ",switch:Lid Switch, exec, mpc -q pause && amixer set Master mute && systemctl suspend"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPause, exec, playerctl play-pause"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPrev, exec, playerctl previous"
      ];

      # Repeat bindings (volume, brightness)
      bindel = [
        ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ",XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+"
        ",XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-"
      ];

      # Window rules
      windowrule = [
        "suppressevent maximize, class:.*"
        "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
        "float, class:^imv$"
        "center, class:^imv$"
        "size 80% 80%, class:^imv$"
        "float, title:^btop$"
        "center, title:^btop$"
        "size 80% 80%, title:^btop$"
        "float, title:^nmtui$"
        "center, title:^nmtui$"
        "size 50% 50%, title:^nmtui$"
        "float, class:^brave-nngceckbapebfimnlniiiahkandclblb-Default$"
        "move 75% 10%, class:^brave-nngceckbapebfimnlniiiahkandclblb-Default$"
        "float, class:^xdg-desktop-portal-gtk$"
        "center, class:^xdg-desktop-portal-gtk$"
      ];
    };
  };
}
