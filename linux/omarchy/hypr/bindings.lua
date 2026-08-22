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

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")
--
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

o.bind("XF86Bluetooth", "Previous track", "omarchy-shell media previous", { locked = true })
o.bind("XF86Keyboard", "Play/pause", "omarchy-shell media playPause", { locked = true })
o.bind("XF86Favorites", "Next track", "omarchy-shell media next", { locked = true })

o.bind("SHIFT + XF86AudioRaiseVolume", "Spotify volume up", "omarchy-shell -q quickshell.spotify.player volumeUp", { locked = true, repeating = true })
o.bind("SHIFT + XF86AudioLowerVolume", "Spotify volume down", "omarchy-shell -q quickshell.spotify.player volumeDown", { locked = true, repeating = true })
