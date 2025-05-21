local M = {}

---Finds a pattern in a line of a file and replaces it with a value
---@param filepath string
---@param pattern string
---@param value string
function M.update_line_in_file(filepath, pattern, value)
    -- First check if file exists and is readable
    if not vim.loop.fs_stat(filepath) then
        vim.notify("File does not exist: " .. filepath, vim.log.levels.ERROR)
        return
    end

    -- Read file safely with pcall
    local ok, lines = pcall(vim.fn.readfile, filepath)
    if not ok or not lines then
        vim.notify("Failed to read file: " .. filepath, vim.log.levels.ERROR)
        return
    end

    -- Process lines
    lines = vim.tbl_map(function(line)
        if vim.fn.match(line, pattern) ~= -1 then
            line = vim.fn.substitute(line, '".*"', value, "")
        end
        return line
    end, lines)

    -- Use a delay and write file safely with pcall
    vim.defer_fn(function()
        local write_ok, err = pcall(vim.fn.writefile, lines, filepath)
        if not write_ok then
            vim.notify("Failed to write file: " .. filepath .. " - " .. (err or "unknown error"), vim.log.levels.ERROR)
        end
    end, 500)
end

---Syncs the wezterm colorscheme with the current nvim colorscheme (if configured)
---@param config VinConfig
---@param colorscheme string
function M.sync_wezterm_colorscheme(config, colorscheme)
    local wezterm_ui_file = config.pathes.config.wezterm .. "/ui.lua"
    local get_hex_color = require("lib.colors").get_hex_color

    local bg_normal = get_hex_color("Normal").bg
    local bg_normal_float = get_hex_color("NormalFloat").bg

    local colorscheme_config = config.colorscheme_config_map[colorscheme]

    if bg_normal then
        M.update_line_in_file(wezterm_ui_file, "background", '"' .. bg_normal .. '"')
    elseif bg_normal_float then
        M.update_line_in_file(wezterm_ui_file, "background", '"' .. bg_normal_float .. '"')
    else
        print("Could not find background color.")
    end

    if colorscheme_config and colorscheme_config.wezterm then
        M.update_line_in_file(wezterm_ui_file, "vin_config_colorscheme", '"' .. colorscheme_config.wezterm .. '"')
    end
end

---Opens a daily note from the specified workspace in a vertical split
---@param workspace_name string The name of the Obsidian workspace
---@param split_cmd? string The split command to use (defaults to "vsplit")
---@return boolean success Whether the note was opened successfully
function M.open_daily_note(workspace_name, split_cmd)
    local obsidian = require("obsidian")
    split_cmd = split_cmd or "vsplit"

    -- Get the client instance
    local client = obsidian.get_client()
    if not client then
        vim.notify("Obsidian client not available", vim.log.levels.ERROR, { title = "Daily Notes" })
        return false
    end

    -- Set the workspace as needed
    local current_ws = client.current_workspace
    if current_ws.name ~= workspace_name then
        -- Try to switch to the requested workspace
        local found = false
        for _, ws in ipairs(client.opts.workspaces or {}) do
            if ws.name == workspace_name then
                client:switch_workspace(workspace_name)
                found = true
                break
            end
        end
        
        if not found then
            vim.notify("Workspace '" .. workspace_name .. "' not found", vim.log.levels.ERROR, { title = "Daily Notes" })
            return false
        end
    end

    -- Get the daily note and open it in a vertical split
    -- This will create the note if it doesn't exist
    local note = client:daily(0) -- 0 for today, offset_days must be provided

    if note and note.path then
        local daily_note_path = note.path.filename
        vim.cmd(split_cmd .. " " .. vim.fn.fnameescape(daily_note_path))
        vim.notify("Opened today's " .. workspace_name .. " note", vim.log.levels.INFO, { title = "Daily Notes" })
        return true
    else
        vim.notify("Failed to open today's " .. workspace_name .. " note", vim.log.levels.ERROR, { title = "Daily Notes" })
        return false
    end
end

return M
