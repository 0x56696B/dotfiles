-- Yabai
local function yabai(command)
	local yabaiPath = "/opt/homebrew/bin/yabai"
	local output, success, status = hs.execute(yabaiPath .. " " .. command)

	hs.console.printStyledtext("Executing: yabai " .. command)
	-- if not success then
	-- 	hs.alert.show("Yabai command failed: " .. output)
	-- end

	return output
end

local function pprint(any, index)
	index = index or 0
	if type(any) == "table" then
		for key, value in pairs(any) do
			if type(value) == "table" then
				print(string.rep("\t", index), key)
				pprint(value, index + 1)
			else
				print(string.rep("\t", index), key, value)
			end
		end
	else
		print(any)
	end
end

local function contains(t, value)
	for _, v in ipairs(t) do
		if v == value then
			return true
		end
	end
	return false
end

local function find_current_space_entry(spaces, winID)
	local match = nil
	for _, entry in ipairs(spaces) do
		if type(entry.windows) == "table" and contains(entry.windows, winID) then
			match = entry
			break
		end
	end

	return match
end

local function is_on_current_space(spaceLabel)
	local winID = hs.window.focusedWindow():id()
	local spacesQuery = yabai("-m query --spaces")

	local parsedSpaces = hs.json.decode(spacesQuery)
	local currentSpace = find_current_space_entry(parsedSpaces, winID)
	pprint(currentSpace)
	print(tostring(spaceLabel))

	return (currentSpace and tostring(currentSpace.label) == spaceLabel) or false
end

local function bind_move_window_to_space(key, spaceLabel)
	hs.hotkey.bind({ "option", "shift" }, key, function()
		if is_on_current_space(spaceLabel) then
			hs.alert.show("This window is on the same space as targeted")
		else
			yabai("-m window --space " .. spaceLabel)
		end
	end)
end

-- Bind focus controls to Alt + H/J/K/L
hs.hotkey.bind({ "alt" }, "h", function()
	yabai("-m window --focus west")
end)

hs.hotkey.bind({ "alt" }, "j", function()
	yabai("-m window --focus south")
end)

hs.hotkey.bind({ "alt" }, "k", function()
	yabai("-m window --focus north")
end)

hs.hotkey.bind({ "alt" }, "l", function()
	yabai("-m window --focus east")
end)

-- Spaces
-- Space num: 1; Name: browser
-- Space num: 2; Name: terminal
-- Space num: 3; Name: comms
-- Space num: 4; Name: dev
-- Space num: 5; Name: temp
--
-- Space num: 5; Name: mail
-- Space num: 6; Name: learning
-- Space num: 7; Name: personal
hs.hotkey.bind("option", "1", function()
	yabai("-m space --focus browser")
end)
hs.hotkey.bind("option", "2", function()
	yabai("-m space --focus terminal")
end)
hs.hotkey.bind("option", "3", function()
	yabai("-m space --focus comms")
end)
hs.hotkey.bind("option", "4", function()
	yabai("-m space --focus dev")
end)
hs.hotkey.bind("option", "5", function()
	yabai("-m space --focus temp")
end)

hs.hotkey.bind("option", "q", function()
	yabai("-m space --focus mail")
end)
hs.hotkey.bind("option", "w", function()
	yabai("-m space --focus learning")
end)
hs.hotkey.bind("option", "e", function()
	yabai("-m space --focus music")
end)
hs.hotkey.bind("option", "r", function()
	yabai("-m space --focus personal")
end)

-- Move windows throught spaces
bind_move_window_to_space("1", "browser")
bind_move_window_to_space("2", "terminal")
bind_move_window_to_space("3", "comms")
bind_move_window_to_space("4", "dev")
bind_move_window_to_space("5", "temp")

bind_move_window_to_space("q", "mail")
bind_move_window_to_space("w", "learning")
bind_move_window_to_space("e", "music")
bind_move_window_to_space("r", "personal")

hs.hotkey.bind({ "control", "option", "shift" }, "r", function()
	yabai("--restart-service")
end)
