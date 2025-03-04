-- Sleep
hs.hotkey.bind({"alt", "shift"}, "L", function()
    hs.caffeinate.systemSleep()
end)

-- Yabai
function yabai(command)
    local yabaiPath = "/opt/homebrew/bin/yabai"
    local success, output, status = hs.execute(yabaiPath .. " " .. command)

    hs.console.printStyledtext("Executing: yabai " .. command)
    if not success then
        hs.alert.show("Yabai command failed: " .. output)
    end

    return output
end

-- Bind focus controls to Alt + H/J/K/L
hs.hotkey.bind({"alt"}, "h", function()
    yabai("-m window --focus west")
end)

hs.hotkey.bind({"alt"}, "j", function()
    yabai("-m window --focus south")
end)

hs.hotkey.bind({"alt"}, "k", function()
    yabai("-m window --focus north")
end)

hs.hotkey.bind({"alt"}, "l", function()
    yabai("-m window --focus east")
end)

-- Spaces
-- Space num: 1; Name: browser
-- Space num: 2; Name: terminal
-- Space num: 3; Name: comms
-- Space num: 4; Name: temp
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
hs.hotkey.bind({ "option", "shift" }, "1", function()
    yabai("-m window --space browser")
end)
hs.hotkey.bind({ "option", "shift" }, "2", function()
    yabai("-m window --space terminal")
end)
hs.hotkey.bind({ "option", "shift" }, "3", function()
    yabai("-m window --space comms")
end)
hs.hotkey.bind({ "option", "shift" }, "4", function()
    yabai("-m window --space temp")
end)

hs.hotkey.bind({ "option", "shift" }, "q", function()
    yabai("-m window --space mail")
end)
hs.hotkey.bind({ "option", "shift" }, "w", function()
    yabai("-m window --space learning")
end)
hs.hotkey.bind({ "option", "shift" }, "e", function()
    yabai("-m window --space music")
end)
hs.hotkey.bind({ "option", "shift" }, "r", function()
    yabai("-m window --space personal")
end)

hs.hotkey.bind({ "control", "option", "shift" }, "r", function ()
  yabai("--restart-service")
end)
