hs.loadSpoon("EmmyLua")

hs.logger.defaultLogLevel = "info"

-- Yabai config
require("yabai")

-- Sleep
hs.hotkey.bind({ "alt", "shift" }, "L", function()
	hs.caffeinate.systemSleep()
end)

-- -- Create an eventtap to listen for "other mouse" button presses
-- local mouseTap = hs.eventtap.new({ hs.eventtap.event.types.otherMouseDown }, function(event)
-- 	-- hs.console.printStyledtext("Event: " .. event)
--
-- 	local buttonNumber = event:getProperty(hs.eventtap.event.properties.mouseEventButtonNumber)
-- 	hs.console.printStyledtext("Mouse button pressed: " .. buttonNumber)
--
-- 	if buttonNumber == 5 then
-- 		hs.spaces.toggleMissionControl()
-- 		return true
-- 	end
--
-- 	return true
-- end)
--
-- -- Start our eventtap
-- mouseTap:start()
