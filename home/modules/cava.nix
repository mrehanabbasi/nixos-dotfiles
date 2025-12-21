{ config, ... }:

{
  catppuccin.cava.enable = true;

  xdg.configFile."cava/shaders".source = ../cava/shaders;

  programs.cava = {
    enable = true;

    settings = {
    ## Configuration file for CAVA.
    # Remove the ; to change parameters.

    general = {
      # Smoothing mode. Can be 'normal', 'scientific' or 'waves'. DEPRECATED as of 0.6.0
      mode = "normal";

      # Accepts only non-negative values.
      framerate = 60;

      # 'autosens' will attempt to decrease sensitivity if the bars peak.
      autosens = 1;
      overshoot = 20;

      # Manual sensitivity in %.
      sensitivity = 100;

      # Bars configuration
      bars = 0;
      bar_width = 2;
      bar_spacing = 1;
      bar_height = 32;

      # center bars in terminal
      center_align = 1;

      # max height of bars in terminal
      max_height = 100;

      # Frequency range
      lower_cutoff_freq = 50;
      higher_cutoff_freq = 10000;

      # Sleep timer
      sleep_timer = 0;
    };

    input = {
      method = "pipewire";
      source = "auto";

      sample_rate = 44100;
      sample_bits = 16;
      channels = 2;

      autoconnect = 2;
      active = 0;
      remix = 1;
      virtual = 1;
    };

    output = {
      # Output method
      method = "noncurses";

      # Orientation
      orientation = "bottom";

      # Channels
      channels = "stereo";
      mono_option = "average";
      reverse = 0;

      # Raw output
      raw_target = "/dev/stdout";
      data_format = "binary";
      bit_format = "16bit";

      ascii_max_range = 1000;
      bar_delimiter = 59;
      frame_delimiter = 10;

      # SDL window
      sdl_width = 1024;
      sdl_height = 512;
      sdl_x = -1;
      sdl_y = -1;
      sdl_full_screen = 0;

      # X axis labels
      xaxis = "none";

      # Sync / rendering
      synchronized_sync = 0;
      vertex_shader = "pass_through.vert";
      fragment_shader = "bar_spectrum.frag";
      continuous_rendering = 0;

      disable_blanking = 0;
      show_idle_bar_heads = 1;
      waveform = 0;
    };

    smoothing = {
      integral = 77;

      monstercat = 0;
      waves = 0;

      gravity = 100;
      ignore = 0;

      noise_reduction = 77;
    };

    eq = {
      "1" = 1; # bass
      "2" = 1;
      "3" = 1; # midtone
      "4" = 1;
      "5" = 1; # treble
    };
  };
  };
}
