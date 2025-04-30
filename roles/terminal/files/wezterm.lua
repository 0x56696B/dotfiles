local wezterm = require("wezterm")

local config = {
	font_size = 11.5,
	font = wezterm.font_with_fallback({
		-- "SF Mono", -- macOS 10.15+  (in /System/Library/Fonts)
		-- "monospace", -- built-in on every Mac
		"JetBrains Mono", -- last-chance fallback
		"Fira Code",
		"Hack",
		"Menlo", -- built-in on every Mac
	}),

	-- Turn *on* standard ligatures
	harfbuzz_features = { "liga" },

	window_decorations = "RESIZE",
	enable_tab_bar = false, -- no tab bar at all :contentReference[oaicite:0]{index=0}
	show_new_tab_button_in_tab_bar = false, -- hide the little “＋”
	enable_scroll_bar = false, -- hide scroll-bar too
	window_close_confirmation = "NeverPrompt", -- Don't ask for confirmation on Quit
	initial_cols = 250, -- bigger than any monitor
	initial_rows = 80,

	-- Without this, wezterm calls wezterm.default_ssh_domains(), which pulls
	-- hosts out of ~/.ssh/config.  An empty table means: “don’t create any”.
	ssh_domains = {},

	disable_default_key_bindings = true, -- no splits, no tabs, nothing :contentReference[oaicite:2]{index=2}
	keys = {
		-- Copy (Cmd-C)
		{ key = "c", mods = "CMD", action = wezterm.action.CopyTo("Clipboard") },
		-- Paste (Cmd-V)
		{ key = "v", mods = "CMD", action = wezterm.action.PasteFrom("Clipboard") },
		-- Quit all (Cmd-Q)
		{ key = "q", mods = "CMD", action = wezterm.action.QuitApplication },
	},
	disable_default_mouse_bindings = true, -- no Ctrl-click, no wheel tab-switch :contentReference[oaicite:3]{index=3}
	mouse_bindings = {},

	check_for_updates = false,
	show_update_window = false,
}

if wezterm.gui then
	local appearance = wezterm.gui.get_appearance()
	if appearance:find("Dark") then
		config.color_scheme = "Catppuccin Macchiato"
	else
		config.color_scheme = "BlulocoLight"
	end
end

return config
