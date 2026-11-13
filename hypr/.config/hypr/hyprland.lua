-- #######################################################################################
-- Hyprland config (Lua format, for Hyprland 0.55+)
-- Migrated from hyprland.conf because Hyprland 0.57 dropped the legacy .conf format.
-- See https://wiki.hypr.land/Configuring/
-- #######################################################################################

------------------
---- PROGRAMS ----
------------------
local terminal    = "kitty"
local fileManager = "kitty yazi"
local menu        = "rofi -show run"
local mainMod     = "SUPER"

------------------
---- MONITORS ----
------------------
-- Monitor 1: ASUS Gaming (izquierda, principal) a 240 Hz
hl.monitor({ output = "DP-3",     mode = "1920x1080@240", position = "0x0",    scale = 1 })
-- Monitor 2: LG Ultrawide (derecha, secundario)
hl.monitor({ output = "HDMI-A-1", mode = "2560x1080@60",  position = "1920x0", scale = 1 })

-- Workspaces -> monitor
if hl.workspace_rule then
  for i = 1, 5 do
    hl.workspace_rule({ workspace = tostring(i), monitor = "DP-3" })
  end
  for i = 6, 10 do
    hl.workspace_rule({ workspace = tostring(i), monitor = "HDMI-A-1" })
  end
end

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------
hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
-- NVIDIA (RTX 5060 Ti)
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("NVD_BACKEND", "direct")

-----------------------
---- LOOK AND FEEL ----
-----------------------
hl.config({
  general = {
    gaps_in = 2,
    gaps_out = 10,
    border_size = 1,
    ["col.active_border"]   = "rgb(808080)",
    ["col.inactive_border"] = "rgb(404040)",
    resize_on_border = false,
    allow_tearing = true,
    layout = "dwindle",
  },
  decoration = {
    rounding = 6,
    rounding_power = 2,
    active_opacity = 0.90,
    inactive_opacity = 0.90,
    shadow = {
      enabled = false,
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
  dwindle = {
    preserve_split = true,
  },
  master = {
    new_status = "master",
  },
  misc = {
    focus_on_activate = true,
    force_default_wallpaper = 0,
    disable_hyprland_logo = true,
    vrr = 1,
  },
  render = {
    direct_scanout = true,
  },
})

---------------
---- INPUT ----
---------------
hl.config({
  input = {
    kb_layout = "es",
    follow_mouse = 1,
    sensitivity = 0,
    touchpad = {
      natural_scroll = false,
    },
  },
})

hl.device({ name = "epic-mouse-v1", sensitivity = -0.5 })

--------------------
---- ANIMATIONS ----
--------------------
if hl.curve and hl.animation then
  hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1}, {0.32, 1} } })
  hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1} } })
  hl.curve("linear",         { type = "bezier", points = { {0, 0}, {1, 1} } })
  hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5}, {0.75, 1.0} } })
  hl.curve("quick",          { type = "bezier", points = { {0.15, 0}, {0.1, 1} } })

  hl.config({ animations = { enabled = true } })

  hl.animation({ leaf = "global",     enabled = true,  speed = 10,   bezier = "default" })
  hl.animation({ leaf = "border",     enabled = true,  speed = 5.39, bezier = "easeOutQuint" })
  hl.animation({ leaf = "windows",    enabled = true,  speed = 4.79, bezier = "easeOutQuint" })
  hl.animation({ leaf = "windowsIn",  enabled = true,  speed = 4.1,  bezier = "easeOutQuint", style = "popin 87%" })
  hl.animation({ leaf = "windowsOut", enabled = true,  speed = 1.49, bezier = "linear",       style = "popin 87%" })
  hl.animation({ leaf = "fadeIn",     enabled = true,  speed = 1.73, bezier = "almostLinear" })
  hl.animation({ leaf = "fadeOut",    enabled = true,  speed = 1.46, bezier = "almostLinear" })
  hl.animation({ leaf = "fade",       enabled = true,  speed = 3.03, bezier = "quick" })
  hl.animation({ leaf = "layers",     enabled = true,  speed = 3.81, bezier = "easeOutQuint" })
  hl.animation({ leaf = "layersIn",   enabled = true,  speed = 4,    bezier = "easeOutQuint", style = "fade" })
  hl.animation({ leaf = "layersOut",  enabled = false, speed = 1.5,  bezier = "linear",       style = "fade" })
  hl.animation({ leaf = "workspaces", enabled = true,  speed = 3,    bezier = "easeOutQuint", style = "slide" })
end

-------------------
---- AUTOSTART ----
-------------------
hl.on("hyprland.start", function()
  hl.exec_cmd("systemctl --user start hyprpolkitagent")
  hl.exec_cmd("eww daemon")
  hl.exec_cmd("waybar")
  hl.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/wallpaper.sh")
  hl.exec_cmd("wl-paste --watch cliphist store")
end)

---------------------
---- KEYBINDINGS ----
---------------------
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))
-- exit: the old `exit` dispatcher is gone in Lua; use uwsm stop as fallback
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || uwsm stop"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("spotify"))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("rofi -show drun"))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Move active window with mainMod + SHIFT + arrow keys
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))

-- Switch / move to workspaces with mainMod (+ SHIFT) + [0-9]
for i = 1, 10 do
  local key = i % 10 -- 10 maps to key 0
  hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
  hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Multimedia keys (locked = work on lockscreen, repeating = autorepeat while held)
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("~/.config/eww/scripts/volume.sh up"),   { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("~/.config/eww/scripts/volume.sh down"), { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("~/.config/eww/scripts/volume.sh mute"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

-- Playback (requires playerctl)
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- Screenshots
hl.bind("Print",         hl.dsp.exec_cmd("grim - | swappy -f -"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd('grim -g "$(slurp)" - | swappy -f -'))

------------------------------
---- WINDOWS & WORKSPACES ----
------------------------------
if hl.window_rule then
  -- Ignore maximize requests from all apps
  hl.window_rule({ name = "suppress-maximize", match = { class = ".*" }, suppress_event = "maximize" })

  -- Fix some dragging issues with XWayland
  hl.window_rule({
    name = "fix-xwayland-drags",
    match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
    no_focus = true,
  })

  hl.window_rule({ name = "move-hyprland-run", match = { class = "hyprland-run" }, float = true })
  hl.window_rule({ name = "ncspot-float", match = { class = "ncspot" }, float = true, size = "1000 600", move = "center" })
  hl.window_rule({ name = "ReadyOrNot", match = { class = "^(ReadyOrNot.*|steam_app_1144200)$" }, monitor = "DP-3", fullscreen = true, immediate = true })
  hl.window_rule({ name = "Starfield", match = { class = "^(starfield\\.exe|steam_app_1716740)$" }, monitor = "DP-3", fullscreen = true, immediate = true })
end

-------------------
---- PLUGINS ------
-------------------
-- The old `plugin { hyprbars { ... } }` block is NOT migrated: hyprbars must be
-- installed via hyprpm, and the Lua plugin-config API is not documented yet.
-- Once hyprbars is installed, configure it per its own docs. Check loaded
-- plugins with: hl.get_loaded_plugins()
