-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")
hl.unbind("SUPER + SHIFT + RETURN") -- previously: Browser
hl.unbind("SUPER + SHIFT + RETURN") -- previously: Browser

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")
--
-- The ThinkPad gear/settings key only emits a tap, even when held.
-- Use it to start and stop dictation.
hl.unbind("F9")
o.bind("XF86Tools", "Toggle dictation", "voxtype record toggle")

-- Tap Print for a screenshot; hold it for 250 ms to dictate.
hl.unbind("PRINT")
o.bind("PRINT", "Screenshot or start dictation", "/home/chris/.local/bin/omarchy-print-dictate press")
o.bind("PRINT", "Finish dictation", "/home/chris/.local/bin/omarchy-print-dictate release", { release = true })

hl.unbind("SUPER + SHIFT + N")
o.bind("SUPER + SHIFT + N", "Notes", "obsidian")

hl.unbind("SUPER + SHIFT + C")
o.bind("SUPER + SHIFT + C", "Google Calendar", { webapp = "https://calendar.google.com/calendar/u/0/r" })

hl.unbind("SUPER + SHIFT + R")
o.bind("SUPER + SHIFT + R", "Beeper", "beeper")

hl.unbind("SUPER + SHIFT + M") -- previously: Music
o.bind("SUPER + SHIFT + M", "Omarchy Spotify full player", "omarchy shell -q quickshell.spotify.player toggleFullPlayer")

hl.unbind("SUPER + SHIFT + E") -- previously: Email
o.bind("SUPER + SHIFT + E", "Email", { webapp = "https://betaapp.fastmail.com" })

hl.unbind("SUPER + SHIFT + SLASH") -- previously: Passwords (1Password)
o.bind("SUPER + SHIFT + SLASH", "Bitwarden", { launch = "bitwarden-desktop" })

hl.unbind("SUPER + O") -- previously: Pop window out (float & pin)
o.bind("SUPER + O", "Pop window out (float & pin)", "omarchy-hyprland-window-pop")

o.bind("XF86Bluetooth", "Previous track", "omarchy-shell media previous", { locked = true })
o.bind("XF86Keyboard", "Play/pause", "omarchy-shell media playPause", { locked = true })
o.bind("XF86Favorites", "Next track", "omarchy-shell media next", { locked = true })

o.bind("SHIFT + XF86AudioRaiseVolume", "Spotify volume up", "omarchy-shell -q quickshell.spotify.player volumeUp", { locked = true, repeating = true })
o.bind("SHIFT + XF86AudioLowerVolume", "Spotify volume down", "omarchy-shell -q quickshell.spotify.player volumeDown", { locked = true, repeating = true })

-- Vim-style window management.
for _, key in ipairs({
  "SUPER + LEFT", "SUPER + RIGHT", "SUPER + UP", "SUPER + DOWN",
  "SUPER + SHIFT + LEFT", "SUPER + SHIFT + RIGHT", "SUPER + SHIFT + UP", "SUPER + SHIFT + DOWN",
  "SUPER + ALT + LEFT", "SUPER + ALT + RIGHT", "SUPER + ALT + UP", "SUPER + ALT + DOWN",
  "SUPER + SHIFT + ALT + LEFT", "SUPER + SHIFT + ALT + RIGHT", "SUPER + SHIFT + ALT + UP", "SUPER + SHIFT + ALT + DOWN",
  "SUPER + J", "SUPER + K", "SUPER + L",
  "SUPER + ALT + K", "SUPER + CTRL + K", "SUPER + CTRL + L",
}) do
  hl.unbind(key)
end

for _, item in ipairs({
  { key = "H", direction = "l", name = "left" },
  { key = "J", direction = "d", name = "down" },
  { key = "K", direction = "u", name = "up" },
  { key = "L", direction = "r", name = "right" },
}) do
  o.bind("SUPER + " .. item.key, "Focus on " .. item.name .. " window", hl.dsp.focus({ direction = item.direction }))
  o.bind("SUPER + SHIFT + " .. item.key, "Swap window " .. item.name, hl.dsp.window.swap({ direction = item.direction }))
  o.bind("SUPER + ALT + " .. item.key, "Move window to group on " .. item.name, hl.dsp.window.move({ into_group = item.direction }))
  o.bind("SUPER + SHIFT + ALT + " .. item.key, "Move workspace to " .. item.name .. " monitor", hl.dsp.workspace.move({ monitor = item.direction }))
end

o.bind("SUPER + CTRL + J", "Toggle window split", hl.dsp.layout("togglesplit"))
o.bind("SUPER + CTRL + K", "Keybindings", "omarchy-menu-keybindings")
o.bind("SUPER + CTRL + L", "Toggle workspace layout", "omarchy-hyprland-workspace-layout-toggle")
-- Previously: Agent picker.
hl.unbind("SUPER + SHIFT + CTRL + A")
o.bind("SUPER + SHIFT + CTRL + A", "Codex (Herdr)", "omarchy-launch-terminal /home/chris/.local/bin/herdr-codex")
o.bind("SUPER + CTRL + ALT + K", "Tmux keybindings", "omarchy-menu-tmux-keybindings")
o.bind("SUPER + SHIFT + CTRL + K", "Herdr keybindings", "omarchy-menu-herdr-keybindings")
o.bind("SUPER + SHIFT + CTRL + L", "Lock system", "omarchy-system-lock")

hl.unbind("SUPER + CTRL + SPACE")
o.bind("SUPER + CTRL + SPACE", "Background switcher", 'background=$(omarchy-theme-bg-switcher); [[ -n $background ]] && omarchy-theme-bg-set "$background"')

-- Super+Alt+arrows avoids Omarchy's keycode-based resize bindings.
for _, key in ipairs({
  "SUPER + ALT + LEFT", "SUPER + ALT + RIGHT",
  "SUPER + SHIFT + ALT + LEFT", "SUPER + SHIFT + ALT + RIGHT",
}) do
  hl.unbind(key)
end
o.bind("SUPER + ALT + RIGHT", "Increase window gaps", "omarchy-adjust-window gaps up")
o.bind("SUPER + ALT + LEFT", "Decrease window gaps", "omarchy-adjust-window gaps down")
o.bind("SUPER + SHIFT + ALT + RIGHT", "Increase active window opacity", "omarchy-adjust-window opacity up")
o.bind("SUPER + SHIFT + ALT + LEFT", "Decrease active window opacity", "omarchy-adjust-window opacity down")
