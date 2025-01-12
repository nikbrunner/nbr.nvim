local M = {}

---Finds a pattern in a line of a file and replaces it with a value
---@param filepath string
---@param pattern string
---@param value string
function M.update_line_in_file(filepath, pattern, value)
    local lines = vim.fn.readfile(filepath)
    lines = vim.tbl_map(function(line)
        if vim.fn.match(line, pattern) ~= -1 then
            line = vim.fn.substitute(line, '".*"', value, "")
        end
        return line
    end, lines)

    vim.fn.writefile(lines, filepath)
end

---Syncs the wezterm colorscheme with the current nvim colorscheme (if configured)
---@param config VinConfig
---@param colorscheme string
function M.sync_wezterm_colorscheme(config, colorscheme)
    local wezterm_ui_file = config.pathes.config.wezterm .. "/ui.lua"
    local get_hex_color = require("nbr.lib.colors").get_hex_color

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
        M.update_line_in_file(wezterm_ui_file, "color_scheme", '"' .. colorscheme_config.wezterm .. '"')
    end
end

---@param config VinConfig
---@param colorscheme string
---@param background string
function M.sync_vin_colorscheme(config, colorscheme, background)
    M.update_line_in_file(config.pathes.config.nbr, "colorscheme", '"' .. colorscheme .. '"')
    M.update_line_in_file(config.pathes.config.nbr, "background", '"' .. background .. '"')
end

return M
