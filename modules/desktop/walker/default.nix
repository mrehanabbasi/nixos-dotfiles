# Walker - Application Launcher with Catppuccin Mocha Blue theme
# Theme based on: https://github.com/krymancer/walker
_:

{
  flake.modules.homeManager.walker = _: {
    programs.walker = {
      enable = true;
      runAsService = true;

      config = {
        theme = "catppuccin-mocha";
        placeholders.default = {
          input = "Search...";
          list = "No results";
        };
        providers.prefixes = [
          {
            provider = "websearch";
            prefix = "+";
          }
          {
            provider = "providerlist";
            prefix = ";";
          }
          {
            provider = "calc";
            prefix = "=";
          }
          {
            provider = "files";
            prefix = "/";
          }
          {
            provider = "clipboard";
            prefix = ":";
          }
          {
            provider = "symbols";
            prefix = ".";
          }
        ];
        keybinds = {
          quick_activate = [
            "F1"
            "F2"
            "F3"
            "F4"
            "F5"
            "F6"
            "F7"
          ];
          # Vim-style navigation
          next = [
            "Down"
            "ctrl j"
          ];
          previous = [
            "Up"
            "ctrl k"
          ];
          down = [
            "Down"
            "ctrl j"
          ];
          up = [
            "Up"
            "ctrl k"
          ];
          left = [
            "Left"
            "ctrl h"
          ];
          right = [
            "Right"
            "ctrl l"
          ];
        };
      };

      # Elephant provider configuration
      elephant = {
        provider.websearch.settings = {
          entries = [
            {
              name = "DuckDuckGo";
              url = "https://duckduckgo.com/?q=%TERM%";
              default = true;
            }
            {
              name = "Google";
              url = "https://www.google.com/search?q=%TERM%";
            }
          ];
        };
      };

      # Catppuccin Mocha theme with Blue accent
      themes = {
        "catppuccin-mocha" = {
          # CSS from https://github.com/krymancer/walker with blue accent modifications
          style = ''
            @define-color rosewater #f5e0dc;
            @define-color flamingo #f2cdcd;
            @define-color pink #f5c2e7;
            @define-color mauve #cba6f7;
            @define-color red #f38ba8;
            @define-color maroon #eba0ac;
            @define-color peach #fab387;
            @define-color yellow #f9e2af;
            @define-color green #a6e3a1;
            @define-color teal #94e2d5;
            @define-color sky #89dceb;
            @define-color sapphire #74c7ec;
            @define-color blue #89b4fa;
            @define-color lavender #b4befe;
            @define-color text #cdd6f4;
            @define-color subtext1 #bac2de;
            @define-color subtext0 #a6adc8;
            @define-color overlay2 #9399b2;
            @define-color overlay1 #7f849c;
            @define-color overlay0 #6c7086;
            @define-color surface2 #585b70;
            @define-color surface1 #45475a;
            @define-color surface0 #313244;
            @define-color base #1e1e2e;
            @define-color mantle #181825;
            @define-color crust #11111b;

            #window,
            #box,
            #aiScroll,
            #aiList,
            #search,
            #password,
            #input,
            #prompt,
            #clear,
            #typeahead,
            #list,
            child,
            scrollbar,
            slider,
            #item,
            #text,
            #label,
            #bar,
            #sub,
            #activationlabel {
              all: unset;
            }

            #cfgerr {
              background: @red;
              margin-top: 20px;
              padding: 8px;
              font-size: 1.2em;
            }

            #window {
              color: @text;
            }

            #box {
              border-radius: 8px;
              background: @base;
              padding: 32px;
              border: 2px solid @blue;
            }

            #search {
              background: @mantle;
              padding: 8px;
              border-radius: 4px;
            }

            #prompt {
              margin-left: 4px;
              margin-right: 12px;
              color: @blue;
              opacity: 0.8;
            }

            #clear {
              color: @text;
              opacity: 0.8;
            }

            #password,
            #input,
            #typeahead {
              border-radius: 2px;
            }

            #input {
              background: none;
            }

            #spinner {
              padding: 8px;
            }

            #typeahead {
              color: @text;
              opacity: 0.8;
            }

            #input placeholder {
              opacity: 0.5;
            }

            child {
              padding: 2px 4px;
              margin: 0;
              border-radius: 4px;
            }

            child:selected,
            child:hover {
              background: alpha(@blue, 0.3);
            }

            /* Reduce vertical spacing in list */
            .list > child {
              margin: 0;
              padding: 1px 4px;
            }

            gridview > child {
              margin: 0;
              padding: 1px 4px;
            }

            #icon {
              margin-right: 4px;
            }

            #text {
              color: @text;
            }

            #label {
              font-weight: 500;
            }

            #sub {
              opacity: 0.5;
              font-size: 0.8em;
            }

            #activationlabel {
              color: @blue;
            }

            .activation #text,
            .activation #icon,
            .activation #search {
              opacity: 0.5;
            }

            .aiItem {
              padding: 10px;
              border-radius: 2px;
              color: @text;
              background: @base;
            }

            .aiItem.user {
              padding-left: 0;
              padding-right: 0;
            }

            .aiItem.assistant {
              background: @mantle;
            }

            /* Additional styling */
            .window {
              background: transparent;
            }

            .box-wrapper {
              background: transparent;
            }

            .box {
              background: @base;
              border: 1px solid @crust;
              border-radius: 8px;
              padding: 16px;
            }

            .search-container {
              background: @mantle;
              border-radius: 4px;
              padding: 8px;
            }

            .input {
              background: transparent;
              color: @text;
            }

            .scroll {
              background: transparent;
            }

            .list {
              background: transparent;
            }

            .item-box {
              padding: 1px 2px;
              margin: 0;
              border-radius: 4px;
            }

            .item-box:selected,
            .item-box:hover {
              background: alpha(@blue, 0.3);
            }

            .item-image {
              margin-right: 4px;
            }

            .item-text {
              color: @text;
              font-weight: 500;
            }

            .item-subtext {
              color: @subtext0;
              font-size: 0.85em;
            }

            .item-quick-activation {
              color: @blue;
              font-weight: bold;
            }

            .placeholder {
              color: @overlay0;
            }

            .error {
              color: @red;
            }

            .keybinds {
              color: @subtext0;
              font-size: 0.85em;
            }

            .preview {
              background: @mantle;
              border-radius: 4px;
              padding: 8px;
            }
          '';

          # XML layouts converted from krymancer's TOML layout
          # https://github.com/krymancer/walker/blob/main/themes/mocha.toml
          layouts = {
            # Main layout - centered box with 450px width, 200px from top
            "layout" = ''
              <?xml version="1.0" encoding="UTF-8"?>
              <interface>
                <requires lib="gtk" version="4.0"/>
                <object class="GtkWindow" id="Window">
                  <style>
                    <class name="window"/>
                  </style>
                  <property name="resizable">true</property>
                  <property name="title">Walker</property>
                  <child>
                    <object class="GtkBox" id="BoxWrapper">
                      <style>
                        <class name="box-wrapper"/>
                      </style>
                      <property name="orientation">vertical</property>
                      <property name="valign">start</property>
                      <property name="halign">center</property>
                      <property name="margin-top">200</property>
                      <property name="width-request">450</property>
                      <child>
                        <object class="GtkBox" id="Box">
                          <style>
                            <class name="box"/>
                          </style>
                          <property name="orientation">vertical</property>
                          <property name="hexpand">true</property>
                          <property name="spacing">8</property>
                          <child>
                            <object class="GtkBox" id="SearchContainer">
                              <style>
                                <class name="search-container"/>
                              </style>
                              <property name="orientation">horizontal</property>
                              <property name="halign">fill</property>
                              <property name="hexpand">true</property>
                              <property name="spacing">8</property>
                              <child>
                                <object class="GtkImage" id="Prompt">
                                  <style>
                                    <class name="prompt"/>
                                  </style>
                                  <property name="icon-name">edit-find</property>
                                  <property name="pixel-size">18</property>
                                  <property name="halign">center</property>
                                  <property name="valign">center</property>
                                </object>
                              </child>
                              <child>
                                <object class="GtkEntry" id="Input">
                                  <style>
                                    <class name="input"/>
                                  </style>
                                  <property name="halign">fill</property>
                                  <property name="hexpand">true</property>
                                  <property name="primary-icon-activatable">false</property>
                                  <property name="secondary-icon-activatable">false</property>
                                </object>
                              </child>
                              <child>
                                <object class="GtkSpinner" id="Spinner">
                                  <style>
                                    <class name="spinner"/>
                                  </style>
                                  <property name="visible">false</property>
                                </object>
                              </child>
                              <child>
                                <object class="GtkImage" id="Clear">
                                  <style>
                                    <class name="clear"/>
                                  </style>
                                  <property name="icon-name">edit-clear</property>
                                  <property name="pixel-size">18</property>
                                  <property name="halign">center</property>
                                  <property name="valign">center</property>
                                </object>
                              </child>
                            </object>
                          </child>
                          <child>
                            <object class="GtkBox" id="ContentContainer">
                              <style>
                                <class name="content-container"/>
                              </style>
                              <property name="orientation">horizontal</property>
                              <property name="spacing">10</property>
                              <child>
                                <object class="GtkLabel" id="ElephantHint">
                                  <style>
                                    <class name="elephant-hint"/>
                                  </style>
                                  <property name="label">Waiting for elephant...</property>
                                  <property name="hexpand">true</property>
                                  <property name="vexpand">true</property>
                                  <property name="visible">false</property>
                                  <property name="valign">center</property>
                                </object>
                              </child>
                              <child>
                                <object class="GtkLabel" id="Placeholder">
                                  <style>
                                    <class name="placeholder"/>
                                  </style>
                                  <property name="label">No Results</property>
                                  <property name="hexpand">true</property>
                                  <property name="vexpand">true</property>
                                  <property name="valign">center</property>
                                </object>
                              </child>
                              <child>
                                <object class="GtkScrolledWindow" id="Scroll">
                                  <style>
                                    <class name="scroll"/>
                                  </style>
                                  <property name="can-focus">false</property>
                                  <property name="overlay-scrolling">true</property>
                                  <property name="hexpand">true</property>
                                  <property name="vexpand">true</property>
                                  <property name="min-content-width">400</property>
                                  <property name="max-content-width">400</property>
                                  <property name="max-content-height">375</property>
                                  <property name="propagate-natural-height">true</property>
                                  <property name="propagate-natural-width">true</property>
                                  <property name="hscrollbar-policy">never</property>
                                  <property name="vscrollbar-policy">automatic</property>
                                  <property name="margin-top">8</property>
                                  <child>
                                    <object class="GtkGridView" id="List">
                                      <style>
                                        <class name="list"/>
                                      </style>
                                      <property name="max-columns">1</property>
                                      <property name="min-columns">1</property>
                                      <property name="can-focus">false</property>
                                    </object>
                                  </child>
                                </object>
                              </child>
                              <child>
                                <object class="GtkBox" id="Preview">
                                  <style>
                                    <class name="preview"/>
                                  </style>
                                </object>
                              </child>
                            </object>
                          </child>
                          <child>
                            <object class="GtkBox" id="Keybinds">
                              <property name="hexpand">true</property>
                              <property name="margin-top">10</property>
                              <style>
                                <class name="keybinds"/>
                              </style>
                              <child>
                                <object class="GtkBox" id="GlobalKeybinds">
                                  <property name="spacing">10</property>
                                  <style>
                                    <class name="global-keybinds"/>
                                  </style>
                                </object>
                              </child>
                              <child>
                                <object class="GtkBox" id="ItemKeybinds">
                                  <property name="hexpand">true</property>
                                  <property name="halign">end</property>
                                  <property name="spacing">10</property>
                                  <style>
                                    <class name="item-keybinds"/>
                                  </style>
                                </object>
                              </child>
                            </object>
                          </child>
                          <child>
                            <object class="GtkLabel" id="Error">
                              <style>
                                <class name="error"/>
                              </style>
                              <property name="xalign">0</property>
                              <property name="visible">false</property>
                            </object>
                          </child>
                        </object>
                      </child>
                    </object>
                  </child>
                </object>
              </interface>
            '';

            # Item layout with icon size 26px and activation label
            "item" = ''
              <?xml version="1.0" encoding="UTF-8"?>
              <interface>
                <requires lib="gtk" version="4.0"/>
                <object class="GtkBox" id="ItemBox">
                  <style>
                    <class name="item-box"/>
                  </style>
                  <property name="orientation">horizontal</property>
                  <property name="spacing">6</property>
                  <child>
                    <object class="GtkLabel" id="ItemImageFont">
                      <style>
                        <class name="item-image-text"/>
                      </style>
                      <property name="width-chars">2</property>
                    </object>
                  </child>
                  <child>
                    <object class="GtkImage" id="ItemImage">
                      <style>
                        <class name="item-image"/>
                      </style>
                      <property name="pixel-size">26</property>
                    </object>
                  </child>
                  <child>
                    <object class="GtkBox" id="ItemTextBox">
                      <style>
                        <class name="item-text-box"/>
                      </style>
                      <property name="orientation">vertical</property>
                      <property name="vexpand">true</property>
                      <property name="hexpand">true</property>
                      <property name="spacing">0</property>
                      <child>
                        <object class="GtkLabel" id="ItemText">
                          <style>
                            <class name="item-text"/>
                          </style>
                          <property name="ellipsize">end</property>
                          <property name="vexpand">true</property>
                          <property name="xalign">0</property>
                        </object>
                      </child>
                      <child>
                        <object class="GtkLabel" id="ItemSubtext">
                          <style>
                            <class name="item-subtext"/>
                          </style>
                          <property name="ellipsize">end</property>
                          <property name="vexpand">true</property>
                          <property name="xalign">0</property>
                          <property name="yalign">0</property>
                        </object>
                      </child>
                    </object>
                  </child>
                  <child>
                    <object class="GtkLabel" id="QuickActivation">
                      <style>
                        <class name="item-quick-activation"/>
                      </style>
                      <property name="wrap">false</property>
                      <property name="valign">center</property>
                      <property name="halign">fill</property>
                      <property name="width-chars">2</property>
                      <property name="xalign">0.5</property>
                      <property name="yalign">0.5</property>
                    </object>
                  </child>
                </object>
              </interface>
            '';
          };
        };
      };
    };
  };
}
