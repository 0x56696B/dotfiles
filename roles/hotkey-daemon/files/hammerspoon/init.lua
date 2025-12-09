hs.logger.setGlobalLogLevel("warning")

-- Yabai config
-- require("yabai")

-- Sleep
hs.hotkey.bind({ "alt", "shift" }, "P", function()
	hs.caffeinate.systemSleep()
end)

-- Experimental tiling in Hammerspoon for yabai replacement
require("tiling")
