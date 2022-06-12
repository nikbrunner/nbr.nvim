local notify_status_ok, notify = pcall(require, "notify")
if not notify_status_ok then
	return
end

Vin.cmds.nav = {}

-- NOTE: Unused - Picker always returns nil
Vin.cmds.nav.pick_window = function()
	local success, picker = pcall(require, "window-picker")

	if success then
		local picked_window_id = picker.pick_window()

		if picked_window_id then
			vim.api.nvim_set_current_win(picked_window_id)
		else
			notify("   Something went wrong", "warn", {
				timeout = 1000,
				render = "minimal",
			})
			return
		end
	end
end
