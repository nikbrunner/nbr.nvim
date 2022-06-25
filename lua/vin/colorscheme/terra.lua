local status_ok, terra = pcall(require, "terra")
if not status_ok then
	return
end

terra.setup({
	-- Main options --
	style = "spring", -- Default theme style. Choose between 'spring', 'dark', 'darker', 'cool', 'warm', 'warmer' and 'light'
	transparent = false, -- Show/hide background
	term_colors = true, -- Change terminal color as per the selected theme style
	ending_tildes = false, -- Show the end-of-buffer tildes. By default they are hidden
	-- toggle theme style ---
	toggle_style_key = "<C-x>", -- Default keybinding to toggle
	toggle_style_list = {
		"spring",
		"dark",
		"darker",
		"cool",
		"warm",
		"warmer",
		"light",
	}, -- List of styles to toggle between

	-- Change code style ---
	-- Options are italic, bold, underline, none
	-- You can configure multiple style with comma seperated, For e.g., keywords = 'italic,bold'
	code_style = {
		comments = "italic",
		keywords = "italic",
		functions = "none",
		strings = "none",
		variables = "bold",
	},

	-- Custom Highlights --
	colors = {}, -- Override default colors
	highlights = {}, -- Override highlight groups

	-- Plugins Config --
	diagnostics = {
		darker = true, -- darker colors for diagnostic
		undercurl = true, -- use undercurl instead of underline for diagnostics
		background = true, -- use background color for virtual text
	},
})
