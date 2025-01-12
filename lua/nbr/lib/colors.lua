local M = {}

---Converts a Hex String to RGB Color String
---@param hex_str string
---@return table
function M.hexToRgb(hex_str)
    local hex = "[abcdef0-9][abcdef0-9]"
    local pat = "^#(" .. hex .. ")(" .. hex .. ")(" .. hex .. ")$"

    hex_str = string.lower(hex_str)

    assert(string.find(hex_str, pat) ~= nil, "hex_to_rgb: invalid hex_str: " .. tostring(hex_str))

    local r, g, b = string.match(hex_str, pat)
    return { tonumber(r, 16), tonumber(g, 16), tonumber(b, 16) }
end

---Based on the hl_group_name, returns the hex color of the background and foreground
---@param hl_group_name string
---@return table
function M.get_hex_color(hl_group_name)
    local opts = { name = hl_group_name }
    local hl_info = vim.api.nvim_get_hl(0, opts) -- 0 for global namespace
    local colors = {}
    if hl_info.bg then
        colors.bg = string.format("#%06x", hl_info.bg)
    end
    if hl_info.fg then
        colors.fg = string.format("#%06x", hl_info.fg)
    end
    return colors
end

---@param fg string foreground color
---@param bg string background color
---@param alpha number number between 0 and 1. 0 results in bg, 1 results in fg
---@return string
function M.blend(fg, bg, alpha)
    local background = M.hexToRgb(bg)
    local foreground = M.hexToRgb(fg)

    local blendChannel = function(i)
        local ret = (alpha * foreground[i] + ((1 - alpha) * background[i]))
        return math.floor(math.min(math.max(0, ret), 255) + 0.5)
    end

    return string.format("#%02X%02X%02X", blendChannel(1), blendChannel(2), blendChannel(3))
end

---Darken a color by blending it with black or a custom color
---@example
---```lua
---darken("#2E3440", 0.8) -- Darkens this color by 20% aka reduces its brightness to 80%
---```
---@param hex_string string
---@param amount number
---@param bg? string
---@return string
function M.darken(hex_string, amount, bg)
    bg = bg or "#000000"
    return M.blend(hex_string, bg, math.abs(amount))
end

---Lighten a color by blending it with white or a custom color
---@example
---```lua
---lighten("#E5E9F0", 0.8) -- Lightens this color by 20% aka increases its brightness to 80%
---```
---@param hex_string string
---@param amount number
---@param fg? string
---@return string
function M.lighten(hex_string, amount, fg)
    fg = fg or "#ffffff"
    return M.blend(hex_string, fg, math.abs(amount))
end

return M
