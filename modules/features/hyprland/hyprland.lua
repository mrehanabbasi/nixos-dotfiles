-- Hyprland config — authored as raw Lua per the upstream example:
-- https://github.com/hyprwm/Hyprland/blob/main/example/hyprland.lua
-- Loaded from default.nix via builtins.readFile.

-- Programs
local terminal    = "ghostty"
local fileManager = terminal .. " -e yazi"
local webBrowser  = "brave --allowlisted-extension-id=clngdbkpkpeebahjckkjfobafhncgmne"
local webBrowser2 = "librewolf"
local cursorTheme = "Catppuccin Mocha Blue"
local cursorSize  = "24"
local mainMod     = "SUPER"

-- Monitors
hl.monitor({ output = "eDP-1", mode = "highres", position = "0x0", scale = 1 })
hl.monitor({ output = "DP-2", mode = "highres", position = "-1920x0", scale = 1 })
hl.monitor({ output = "", mode = "highres", position = "auto", scale = 1 })

-- Autostart
-- Note: kdeconnect is started via kdeconnect.nix (services.kdeconnect.indicator)
-- Note: DMS handles wallpaper, notifications, and Bluetooth via systemd
hl.on("hyprland.start", function()
  hl.exec_cmd("hyprctl setcursor " .. cursorTheme .. " " .. cursorSize)
  -- Fallback: re-detect monitors if USB-C DP alt mode was slow
  hl.exec_cmd("sleep 3 && hyprctl reload")
  hl.exec_cmd("proton-mail")
  hl.exec_cmd("fastmail")
  hl.exec_cmd("ghostty -e nixos-session")
end)

-- Environment
hl.env("XCURSOR_SIZE", cursorSize)
hl.env("QT_QPA_PLATFORMTHEME", "gtk3")
hl.env("QT_QPA_PLATFORMTHEME_QT6", "gtk3")

-- General / decoration / layouts / misc / input
hl.config({
  general    = {
    gaps_in = 2,
    gaps_out = 5,
    border_size = 1,
    col = {
      active_border   = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
      inactive_border = "rgba(595959aa)",
    },
    resize_on_border = false,
    allow_tearing = false,
    layout = "dwindle",
  },

  decoration = {
    rounding = 4,
    rounding_power = 2,
    active_opacity = 1.0,
    inactive_opacity = 0.95,
    shadow = {
      enabled = true,
      range = 4,
      render_power = 3,
      color = "rgba(1a1a1aee)",
    },
    blur = {
      enabled = true,
      size = 3,
      passes = 1,
      vibrancy = 0.1696,
    },
  },

  animations = { enabled = true },

  dwindle    = { preserve_split = true },
  master     = { new_status = "master" },

  misc       = {
    force_default_wallpaper = 0,
    disable_hyprland_logo = false,
  },

  input      = {
    kb_layout = "us",
    follow_mouse = 1,
    sensitivity = 0,
    touchpad = {
      natural_scroll = true,
    },
  },
})

-- Animation curves and animations
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 7, bezier = "quick" })

-- Gestures
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- Keybindings
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd("thunar"))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd("dms ipc call spotlight open"))
hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd("hyprshot -m region"))
hl.bind(mainMod .. " + SHIFT + Print", hl.dsp.exec_cmd("hyprshot -m output"))
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd("hyprpicker"))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + S", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(webBrowser))
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd(webBrowser2))
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal .. " --title='btop' -e btop"))
hl.bind(mainMod .. " + SEMICOLON", hl.dsp.exec_cmd("dms ipc call lock lock"))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("dms ipc call notifications toggle"))
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("dms ipc call notifications clearAll"))
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd("pavucontrol"))
hl.bind(mainMod .. " + SHIFT + A", hl.dsp.exec_cmd("voxtype record toggle"))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(mainMod .. " + X", hl.dsp.exec_cmd("dms ipc call powermenu toggle"))

-- Cycle between windows in same workspace
hl.bind("ALT + Tab", hl.dsp.window.cycle_next())
hl.bind("ALT + Tab", hl.dsp.window.alter_zorder({ mode = "top" }))
hl.bind("ALT + SHIFT + Tab", hl.dsp.window.cycle_next({ next = false }))
hl.bind("ALT + SHIFT + Tab", hl.dsp.window.alter_zorder({ mode = "top" }))

-- DMS clipboard
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd("dms ipc call clipboard toggle"))

-- Focus with vim keys
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))

-- Workspaces 1-10 (10 mapped to key 0) and move-to-workspace
for i = 1, 10 do
  local key = i % 10
  hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
  hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Swap windows with vim keys
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.swap({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.swap({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.swap({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.swap({ direction = "down" }))

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + W", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Email special workspace (Proton Mail + Fastmail)
hl.bind(mainMod .. " + M", hl.dsp.workspace.toggle_special("email"))

-- Scroll through workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Resize windows
hl.bind(mainMod .. " + SHIFT + UP", hl.dsp.window.resize({ x = 0, y = -20, relative = true }))
hl.bind(mainMod .. " + SHIFT + DOWN", hl.dsp.window.resize({ x = 0, y = 20, relative = true }))
hl.bind(mainMod .. " + SHIFT + LEFT", hl.dsp.window.resize({ x = -20, y = 0, relative = true }))
hl.bind(mainMod .. " + SHIFT + RIGHT", hl.dsp.window.resize({ x = 20, y = 0, relative = true }))

-- Move workspace to monitor
hl.bind(mainMod .. " + Tab", hl.dsp.workspace.move({ monitor = "+1" }))
hl.bind(mainMod .. " + SHIFT + Tab", hl.dsp.workspace.move({ monitor = "-1" }))

-- Mouse drag/resize
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Lid switch - lock before suspend for better stability
hl.bind("switch:Lid Switch", hl.dsp.exec_cmd("loginctl lock-session && sleep 1 && systemctl suspend"), { locked = true })

-- Media keys
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- Volume and brightness (repeating)
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
  { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
  { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
  { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

-- Workspace rules
hl.workspace_rule({
  workspace = "special:email",
  on_created_empty = "[silent] proton-mail; [silent] fastmail",
  persistent = true,
})

-- Window rules
hl.window_rule({
  name = "no-border-single-tiled",
  match = { workspace = "w[t1]" },
  border_size = 0,
})

hl.window_rule({ match = { class = "^proton-mail$" }, workspace = "special:email silent" })
hl.window_rule({ match = { class = "^com-fastmail-fastmail$" }, workspace = "special:email silent" })

hl.window_rule({
  name = "suppress-maximize",
  match = { class = ".*" },
  suppress_event = "maximize",
})

hl.window_rule({
  name = "fix-xwayland-drags",
  match = {
    class      = "^$",
    title      = "^$",
    xwayland   = true,
    float      = true,
    fullscreen = false,
    pin        = false,
  },
  no_focus = true,
})

hl.window_rule({ match = { class = "^imv$" }, float = true, center = true, size = { "80%", "80%" } })
hl.window_rule({ match = { title = "^btop$" }, float = true, center = true, size = { "80%", "80%" } })
hl.window_rule({ match = { title = "^nmtui$" }, float = true, center = true, size = { "50%", "50%" } })

hl.window_rule({
  match = { class = "^brave-nngceckbapebfimnlniiiahkandclblb-Default$" },
  float = true,
  move  = { "75%", "10%" },
})

hl.window_rule({ match = { class = "^xdg-desktop-portal-gtk$" }, float = true, center = true })

hl.window_rule({
  match  = { class = "^org.kde.kalk$" },
  float  = true,
  center = true,
  size   = { "50%", "80%" },
})
