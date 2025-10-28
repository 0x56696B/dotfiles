local tilingHelpers = require("tiling-helpers")
local logger = require("logger")

local log = logger.new("autosplit", "info")
local windowFilter = hs.window.filter.new(nil)

hs.window.animationDuration = 0
log.i("Accessibility enabled? ", hs.accessibilityState())

if hs.axuielement and hs.axuielement.setMessagingTimeout then
	hs.axuielement.setMessagingTimeout(1.0) -- try 1.0–1.5s if needed
end

windowFilter:subscribe(hs.window.filter.windowCreated, function(win)
	-- wrap AX calls defensively to avoid surfacing AX errors
	local okScreen, screen = pcall(function()
		return win:screen()
	end)
	if not okScreen or not screen then
		log.i("No screen found. Returning...")
		return
	end

	local app = win:application()
	log.i("New application window", app:name(), app:bundleID(), app:pid(), app:kind(), app:path())
	-- skip dialogs or certain apps
	if
		app
		and (
			app:name() == "System Settings"
			or app:name() == "Finder"
			or app:name() == "Raycast"
			or app:name() == "Hammerspoon"
			or app:name() == "Control Center"
		)
	then
		log.i("Application ignored: ", app:name())
		return
	end

	-- only proceed if still a standard, visible window
	local okStd = pcall(function()
		return win:isStandard() and not win:isMinimized()
	end)
	if not okStd or not okStd then
		return
	end

	-- Small timer to let windows init
	hs.timer.doAfter(0.12, function()
		-- find other windows on same screen in current space (excluding the new one)
		local wins = tilingHelpers.windowsOnScreenCurrentSpace(screen)
		local others = {}
		for _, w in ipairs(wins) do
			if w:id() ~= win:id() then
				table.insert(others, w)
			end
		end

		log.i("Current windows: ", wins, others)

		-- only split when there is EXACTLY one other window
		if #others == 1 then
			local existing = others[1]
			tilingHelpers.tileLeftRight(existing, win, screen)
		else
			-- Maximize the new window
			win:maximize()
		end
	end)
end)

hs.alert.show("Auto-tiling active")
