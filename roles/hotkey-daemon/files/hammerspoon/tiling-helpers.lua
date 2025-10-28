local M = {}

-- SAFETY: get windows on current Space for a given screen
function M.windowsOnScreenCurrentSpace(screen)
	local wins = hs.window.filter.defaultCurrentSpace:getWindows(hs.window.filter.sortByFocusedLast)
	local out = {}
	for _, w in ipairs(wins) do
		if w:isStandard() and not w:isMinimized() and w:screen() == screen then
			table.insert(out, w)
		end
	end
	return out
end

-- Internal: robust way to get a visible frame; fall back to full frame
local function safeVisibleFrame(screen)
	if not screen then
		return nil
	end
	-- visibleFrame can fail if the screen isn’t fully resolved yet
	local ok, vf = pcall(function()
		return screen:visibleFrame()
	end)
	if ok and vf then
		return vf
	end
	-- fallback
	return screen:frame()
end

-- Internal: pick a screen if caller didn’t pass one
local function resolveScreen(existingWin, newWin, screen)
	if screen and type(screen) == "userdata" then
		return screen
	end
	if newWin and newWin.screen then
		local s = newWin:screen()
		if s then
			return s
		end
	end
	if existingWin and existingWin.screen then
		local s = existingWin:screen()
		if s then
			return s
		end
	end
	return hs.screen.mainScreen()
end

-- Tile existing -> right half, new -> left half
-- You may call with (existingWin, newWin) or (existingWin, newWin, screen)
function M.tileLeftRight(existingWin, newWin, screen)
	local s = resolveScreen(existingWin, newWin, screen)
	if not s then
		hs.alert.show("No screen found for tiling")
		return
	end

	local f = safeVisibleFrame(s)
	if not f then
		hs.alert.show("No frame for screen")
		return
	end

	local halfW = math.floor(f.w / 2 + 0.5)
	local left = { x = f.x, y = f.y, w = halfW, h = f.h }
	local right = { x = f.x + halfW, y = f.y, w = f.w - halfW, h = f.h }

	if existingWin and existingWin:isStandard() then
		existingWin:setFrame(right, 0)
	end
	if newWin and newWin:isStandard() then
		newWin:setFrame(left, 0)
	end
end

return M
