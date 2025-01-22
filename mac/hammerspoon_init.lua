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

hs.hotkey.bind({ "cmd", "shift" }, "T", function()
	local traceId = hs.pasteboard.getContents()
	local url = "https://observe.shopify.io/a/observe/investigate/requests?trace_id=" .. traceId
	local log = hs.logger.new("config")
	log.setLogLevel("info")
	log.i("Opening", url)
	hs.execute("open " .. url)
end)
