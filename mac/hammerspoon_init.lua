hs.loadSpoon("ReloadConfiguration")
spoon.ReloadConfiguration:start()

hs.hotkey.bind({ "cmd", "shift" }, "return", function()
	hs.execute("nohup kitty -d $HOME < /dev/null &> /dev/null &", true)
end)

--- Shift volume up/down for changing Spotify volume
spotify_volume_handler = hs.eventtap
	.new({ hs.eventtap.event.types.systemDefined }, function(event)
		local currentMods = event:getFlags()
		local data = event:systemKey()

		if data["key"] ~= "SOUND_UP" and data["key"] ~= "SOUND_DOWN" then
			return false, nil
		end

		if not currentMods["shift"] then
			return false, nil
		end

		if data["key"] == "SOUND_UP" then
			hs.spotify.setVolume(hs.spotify.getVolume() + 3)
		else
			hs.spotify.setVolume(hs.spotify.getVolume() - 3)
		end
		return true
	end)
	:start()
