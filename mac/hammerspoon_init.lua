hs.loadSpoon("ReloadConfiguration")
spoon.ReloadConfiguration:start()

hs.hotkey.bind({"cmd", "shift"}, "return", function()
    io.popen("/opt/homebrew/bin/kitty -d $HOME /opt/homebrew/bin/tmux")
end)

hs.hotkey.bind({"cmd", "shift"}, "h", function()
    if hs.window.focusedWindow():focusWindowWest() then
        local w = hs.window.focusedWindow()
        hs.mouse.absolutePosition(w:frame().center)
    end
end)

hs.hotkey.bind({"cmd", "shift"}, "l", function()
    if hs.window.focusedWindow():focusWindowEast() then
        local w = hs.window.focusedWindow()
        hs.mouse.absolutePosition(w:frame().center)
    end
end)

--- Shift volume up/down for changing Spotify volume
hs.eventtap.new({hs.eventtap.event.types.systemDefined}, function(event)
    local currentMods = event:getFlags()
    local data = event:systemKey()

    if data["key"] ~= "SOUND_UP" and data["key"] ~= "SOUND_DOWN" then
        return false, nil
    end

    if not currentMods["shift"] then
        return false, nil
    end

    if data["key"] == "SOUND_UP" then
        hs.spotify.volumeUp()
    else
        hs.spotify.volumeDown()
    end
    return true
end):start()

--- Mouse wheel zoom in Chrome
hs.eventtap.new({hs.eventtap.event.types.scrollWheel}, function(event)
    local currentMods = event:getFlags()

    if not currentMods["cmd"] then
        return false, nil
    end

    local window = hs.window.focusedWindow()

    if window:application():name() ~= "Google Chrome" then
        return false, nil
    end

    local direction = event:getProperty(hs.eventtap.event.properties.scrollWheelEventFixedPtDeltaAxis1)

    local key
    if direction > 0 then
        key = "="
    else
        key = "-"
    end

    hs.eventtap.keyStroke({"cmd"}, key, 100)
    return true, nil
end):start()
