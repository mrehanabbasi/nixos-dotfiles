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

-- Single source of truth for locking. DMS owns lock and idle on this host
-- (see dank-material-shell/default.nix); hypridle/hyprlock are not in the path.
local lockCmd     = "dms ipc call lock lock"

-- Monitors (dynamic; `hyprctl keyword` is unusable under the Lua parser, so
-- layout is applied with hl.monitor() from Lua on startup and on hotplug).
--
-- Externals are identified by model rather than connector, so they keep working
-- no matter which port they land on. Models come from the monitor description —
-- list them with: hyprctl monitors all | grep description
local INTERNAL        = "eDP-1"
local PRIMARY_MODEL   = "DELL SE2422H" -- default display
local SECONDARY_MODEL = "DELL U2424HE" -- extends to the LEFT of primary
local INTERNAL_WIDTH  = 1920           -- fallback; eDP-1 is absent while disabled

local function find_by_model(monitors, model)
  for _, m in ipairs(monitors) do
    if m.description and string.find(m.description, model, 1, true) then
      return m
    end
  end
  return nil
end

-- Returns primary, secondary, internal for the currently connected set
local function detect_monitors()
  local monitors = hl.get_monitors() or {}
  local internal
  for _, m in ipairs(monitors) do
    if m.name == INTERNAL then internal = m end
  end
  return find_by_model(monitors, PRIMARY_MODEL), find_by_model(monitors, SECONDARY_MODEL), internal
end

local function configure_monitors()
  local primary, secondary, internal = detect_monitors()

  if primary and secondary then
    -- Both externals: laptop panel off, secondary left of primary
    hl.monitor({ output = INTERNAL, disabled = true })
    hl.monitor({ output = secondary.name, mode = "highres", position = "0x0", scale = 1 })
    hl.monitor({ output = primary.name, mode = "highres", position = secondary.width .. "x0", scale = 1 })
  elseif primary or secondary then
    -- Single external: eDP-1 stays primary, external extends to its right
    local ext = primary or secondary
    hl.monitor({ output = INTERNAL, mode = "highres", position = "0x0", scale = 1 })
    hl.monitor({
      output = ext.name,
      mode = "highres",
      position = (internal and internal.width or INTERNAL_WIDTH) .. "x0",
      scale = 1,
    })
  else
    hl.monitor({ output = INTERNAL, mode = "highres", position = "0x0", scale = 1 })
  end
end

hl.monitor({ output = "", mode = "highres", position = "auto", scale = 1 })
configure_monitors()

-- Debounce disconnects: DP monitors often drop the link on sleep/standby,
-- firing a real monitor.removed even though nothing was unplugged. Wait a
-- few seconds before reflowing so a quick sleep/wake doesn't relayout;
-- a genuine unplug still lands after the delay.
local REMOVAL_DEBOUNCE_MS = 8000
local pending_removal_timer = nil

hl.on("monitor.added", function(_)
  if pending_removal_timer then
    pending_removal_timer:set_enabled(false)
    pending_removal_timer = nil
  end
  configure_monitors()
end)

hl.on("monitor.removed", function(_)
  if pending_removal_timer then pending_removal_timer:set_enabled(false) end
  pending_removal_timer = hl.timer(function()
    pending_removal_timer = nil
    configure_monitors()
  end, { timeout = REMOVAL_DEBOUNCE_MS, type = "oneshot" })
end)

-- Autostart
-- Note: kdeconnect is started via kdeconnect.nix (services.kdeconnect.indicator)
-- Note: DMS handles wallpaper, notifications, and Bluetooth via systemd
hl.on("hyprland.start", function()
  hl.exec_cmd("hyprctl setcursor " .. cursorTheme .. " " .. cursorSize)
  configure_monitors()
  -- Fallback: re-detect monitors if USB-C DP alt mode was slow
  hl.timer(configure_monitors, { timeout = 3000, type = "oneshot" })
  hl.exec_cmd("proton-mail")
  hl.exec_cmd("fastmail")
  hl.exec_cmd("ghostty --class=nixos-session -e nixos-session")
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
    -- Mouse edge-drag resize. border_size is 1px, so the grab area has to be
    -- extended or the border is unhittable in practice.
    resize_on_border = true,
    extend_border_grab_area = 15,
    allow_tearing = false,
    layout = "dwindle",
  },

  binds      = {
    -- SUPER+Tab returns to the previous workspace; re-pressing a workspace key
    -- you are already on also bounces back.
    workspace_back_and_forth = true,
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

-- ===========================================================================
-- Keybindings
--
-- Modifier grammar for directional keys (h/j/k/l):
--   SUPER              focus window
--   SUPER + SHIFT      swap window
--   SUPER + CTRL       focus monitor          (h/l only)
--   SUPER + CTRL+SHIFT move window to monitor (h/l only)
--   SUPER + ALT        move workspace to monitor (h/l only)
-- SHIFT consistently means "bring the window along".
--
-- Every bind carries a description so `hyprctl binds -j` can render a cheatsheet.
-- ===========================================================================

local RESIZE_STEP = 40 -- px per press for the quick-nudge binds and resize mode
local RESIZE_FINE = 10 -- px per press when holding SHIFT inside resize mode

local function bind(keys, dispatcher, desc, opts)
  opts = opts or {}
  opts.description = desc
  return hl.bind(keys, dispatcher, opts)
end

-- Applications
bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal), "Terminal")
bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager), "File manager (yazi)")
bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd("thunar"), "File manager (Thunar)")
bind(mainMod .. " + B", hl.dsp.exec_cmd(webBrowser), "Browser (Brave)")
bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd(webBrowser2), "Browser (LibreWolf)")
bind(mainMod .. " + T",
  hl.dsp.exec_cmd(terminal .. " --title='btop' --window-width=140 --window-height=35 -e btop"),
  "System monitor (btop)")
bind(mainMod .. " + A", hl.dsp.exec_cmd("pavucontrol"), "Audio mixer")
bind(mainMod .. " + D", hl.dsp.exec_cmd("voxtype record toggle"), "Dictation: toggle recording")

-- Shell (DMS)
bind(mainMod .. " + Space", hl.dsp.exec_cmd("dms ipc call spotlight open"), "App launcher")
bind(mainMod .. " + V", hl.dsp.exec_cmd("dms ipc call clipboard toggle"), "Clipboard history")
bind(mainMod .. " + N", hl.dsp.exec_cmd("dms ipc call notifications toggle"), "Notification centre")
bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("dms ipc call notifications clearAll"), "Clear notifications")
bind(mainMod .. " + X", hl.dsp.exec_cmd("dms ipc call powermenu toggle"), "Power menu")
-- SUPER+? - '?' is SHIFT+/, so the chord is bound on the slash key.
-- Reads `hyprctl binds -j`, so it always reflects what is actually loaded.
bind(mainMod .. " + SHIFT + SLASH", hl.dsp.exec_cmd("hypr-cheatsheet"), "Show keyboard shortcuts")
bind(mainMod .. " + SEMICOLON", hl.dsp.exec_cmd(lockCmd), "Lock session")

-- Window state
bind(mainMod .. " + Q", hl.dsp.window.close(), "Close window")
bind(mainMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }), "Toggle fullscreen")
bind(mainMod .. " + SHIFT + Space", hl.dsp.window.float({ action = "toggle" }), "Toggle floating")
bind(mainMod .. " + P", hl.dsp.window.pin(), "Pin window (floating, all workspaces)")
bind(mainMod .. " + C", hl.dsp.window.center(), "Centre floating window")
bind(mainMod .. " + S", hl.dsp.layout("togglesplit"), "Toggle dwindle split direction")
bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd("hyprctl reload"), "Reload Hyprland config")

-- Groups (tabbed windows)
bind(mainMod .. " + G", hl.dsp.group.toggle(), "Toggle group (tab windows together)")
bind(mainMod .. " + SHIFT + G", hl.dsp.group.lock({ action = "toggle" }), "Lock/unlock group")
bind(mainMod .. " + COMMA", hl.dsp.group.prev(), "Group: previous tab")
bind(mainMod .. " + PERIOD", hl.dsp.group.next(), "Group: next tab")

-- Screenshots
-- hyprshot saves to disk *and* copies to the clipboard unless --clipboard-only.
-- --freeze pins the screen while a region is selected.
bind("Print", hl.dsp.exec_cmd("hyprshot -m output"), "Screenshot: current workspace")
bind(mainMod .. " + Print", hl.dsp.exec_cmd("hyprshot -z -m region"), "Screenshot: select region")
bind(mainMod .. " + SHIFT + Print", hl.dsp.exec_cmd("hyprshot -z -m region --clipboard-only"),
  "Screenshot: region to clipboard only")
bind(mainMod .. " + CTRL + Print", hl.dsp.exec_cmd("hyprshot -z -m window"), "Screenshot: pick a window")
bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd("hyprpicker"), "Pick colour under cursor")

-- Window focus (vim keys)
bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }), "Focus left")
bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }), "Focus right")
bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }), "Focus up")
bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }), "Focus down")

-- Swap windows (vim keys)
bind(mainMod .. " + SHIFT + H", hl.dsp.window.swap({ direction = "left" }), "Swap window left")
bind(mainMod .. " + SHIFT + L", hl.dsp.window.swap({ direction = "right" }), "Swap window right")
bind(mainMod .. " + SHIFT + K", hl.dsp.window.swap({ direction = "up" }), "Swap window up")
bind(mainMod .. " + SHIFT + J", hl.dsp.window.swap({ direction = "down" }), "Swap window down")

-- Cycle windows within the workspace
bind("ALT + Tab", hl.dsp.window.cycle_next(), "Cycle windows")
hl.bind("ALT + Tab", hl.dsp.window.alter_zorder({ mode = "top" }))
bind("ALT + SHIFT + Tab", hl.dsp.window.cycle_next({ next = false }), "Cycle windows (reverse)")
hl.bind("ALT + SHIFT + Tab", hl.dsp.window.alter_zorder({ mode = "top" }))

-- Monitors
bind(mainMod .. " + CTRL + H", hl.dsp.focus({ monitor = "-1" }), "Focus monitor left")
bind(mainMod .. " + CTRL + L", hl.dsp.focus({ monitor = "+1" }), "Focus monitor right")
bind(mainMod .. " + CTRL + SHIFT + H", hl.dsp.window.move({ monitor = "-1" }), "Move window to monitor left")
bind(mainMod .. " + CTRL + SHIFT + L", hl.dsp.window.move({ monitor = "+1" }), "Move window to monitor right")
bind(mainMod .. " + ALT + H", hl.dsp.workspace.move({ monitor = "-1" }), "Move workspace to monitor left")
bind(mainMod .. " + ALT + L", hl.dsp.workspace.move({ monitor = "+1" }), "Move workspace to monitor right")

-- Workspaces 1-10 (10 mapped to key 0)
for i = 1, 10 do
  local key = i % 10
  bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }), "Go to workspace " .. i)
  bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }), "Move window to workspace " .. i)
  bind(mainMod .. " + CTRL + " .. key, hl.dsp.window.move({ workspace = i, silent = true }),
    "Move window to workspace " .. i .. " (stay here)")
end

-- Workspace navigation
bind(mainMod .. " + Tab", hl.dsp.focus({ workspace = "previous" }), "Previous workspace (back and forth)")
bind(mainMod .. " + BRACKETLEFT", hl.dsp.focus({ workspace = "e-1" }), "Workspace back")
bind(mainMod .. " + BRACKETRIGHT", hl.dsp.focus({ workspace = "e+1" }), "Workspace forward")
bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }), "Workspace forward (scroll)")
bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }), "Workspace back (scroll)")

-- Special workspaces
bind(mainMod .. " + W", hl.dsp.workspace.toggle_special("magic"), "Toggle scratchpad")
bind(mainMod .. " + SHIFT + W", hl.dsp.window.move({ workspace = "special:magic" }), "Move window to scratchpad")
bind(mainMod .. " + M", hl.dsp.workspace.toggle_special("email"), "Toggle email workspace")

-- Resize: quick nudge. `repeating` is what makes this usable - without it every
-- step costs a discrete keypress.
bind(mainMod .. " + SHIFT + UP", hl.dsp.window.resize({ x = 0, y = -RESIZE_STEP, relative = true }),
  "Shrink window vertically", { repeating = true })
bind(mainMod .. " + SHIFT + DOWN", hl.dsp.window.resize({ x = 0, y = RESIZE_STEP, relative = true }),
  "Grow window vertically", { repeating = true })
bind(mainMod .. " + SHIFT + LEFT", hl.dsp.window.resize({ x = -RESIZE_STEP, y = 0, relative = true }),
  "Shrink window horizontally", { repeating = true })
bind(mainMod .. " + SHIFT + RIGHT", hl.dsp.window.resize({ x = RESIZE_STEP, y = 0, relative = true }),
  "Grow window horizontally", { repeating = true })

-- Resize mode: SUPER+R enters, hjkl/arrows resize freely, SHIFT for fine steps,
-- Escape/Return/SUPER+R leaves. Resizing is a mode, not a series of keypresses.
local RESIZE_DIRS = {
  H = { -1, 0 }, L = { 1, 0 }, K = { 0, -1 }, J = { 0, 1 },
  LEFT = { -1, 0 }, RIGHT = { 1, 0 }, UP = { 0, -1 }, DOWN = { 0, 1 },
}

hl.define_submap("resize", function()
  for key, d in pairs(RESIZE_DIRS) do
    hl.bind(key,
      hl.dsp.window.resize({ x = d[1] * RESIZE_STEP, y = d[2] * RESIZE_STEP, relative = true }),
      { repeating = true })
    hl.bind("SHIFT + " .. key,
      hl.dsp.window.resize({ x = d[1] * RESIZE_FINE, y = d[2] * RESIZE_FINE, relative = true }),
      { repeating = true })
  end
  hl.bind("Escape", hl.dsp.submap("reset"))
  hl.bind("RETURN", hl.dsp.submap("reset"))
  hl.bind(mainMod .. " + R", hl.dsp.submap("reset"))
end)

bind(mainMod .. " + R", hl.dsp.submap("resize"), "Resize mode (hjkl/arrows, Esc to exit)")

-- Mouse drag/resize
bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), "Drag window", { mouse = true })
bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), "Resize window with mouse", { mouse = true })

-- Lid switch - skip suspend when a known external monitor is connected.
-- Uses the same locker as SUPER+SEMICOLON; DMS owns lock and idle on this host.
hl.bind("switch:Lid Switch", function()
  local primary, secondary = detect_monitors()
  if not (primary or secondary) then
    hl.exec_cmd(lockCmd)
    hl.timer(function() hl.exec_cmd("systemctl suspend") end, { timeout = 1000, type = "oneshot" })
  end
end, { locked = true })

-- Media keys
bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), "Next track", { locked = true })
bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), "Play/pause", { locked = true })
bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), "Play/pause", { locked = true })
bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), "Previous track", { locked = true })

-- Volume and brightness. Only the continuous controls repeat - a toggle that
-- repeats just flaps its own state while the key is held.
bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
  "Volume up", { locked = true, repeating = true })
bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
  "Volume down", { locked = true, repeating = true })
bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
  "Mute output", { locked = true })
bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
  "Mute microphone", { locked = true })
bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),
  "Brightness up", { locked = true, repeating = true })
bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),
  "Brightness down", { locked = true, repeating = true })

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
hl.window_rule({ match = { class = "^com\\.fastmail\\.Fastmail$" }, workspace = "special:email silent" })
hl.window_rule({ match = { class = "^nixos-session$" }, workspace = "1 silent" })

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
