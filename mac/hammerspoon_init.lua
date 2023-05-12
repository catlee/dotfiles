hs.loadSpoon("ReloadConfiguration")
spoon.ReloadConfiguration:start()

hs.hotkey.bind({ "cmd", "shift" }, "return", function()
    hs.execute("nohup kitty -d $HOME zellij attach -c < /dev/null &> /dev/null &", true)
end)

hs.hotkey.bind({ "cmd", "shift" }, "h", function()
    if hs.window.focusedWindow():focusWindowWest() then
        local w = hs.window.focusedWindow()
        hs.mouse.absolutePosition(w:frame().center)
    end
end)

hs.hotkey.bind({ "cmd", "shift" }, "l", function()
    if hs.window.focusedWindow():focusWindowEast() then
        local w = hs.window.focusedWindow()
        hs.mouse.absolutePosition(w:frame().center)
    end
end)

--- Shift volume up/down for changing Spotify volume
spotify_volume_handler = hs.eventtap.new({ hs.eventtap.event.types.systemDefined }, function(event)
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
