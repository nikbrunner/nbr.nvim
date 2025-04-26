local darken = require("lib.colors").darken
local lighten = require("lib.colors").lighten
local bit = require("bit")

---@param dec number
local function dec_to_hex(dec)
    dec = dec or 0
    local r = bit.rshift(bit.band(dec, 0xFF0000), 16)
    local g = bit.rshift(bit.band(dec, 0x00FF00), 8)
    local b = bit.band(dec, 0x0000FF)
    return string.format("#%02X%02X%02X", r, g, b)
end

--- @param name string Highlight group name, e.g. "ErrorMsg"
--- @param opts vim.api.keyset.highlight Highlight definition map, accepts the following keys:
local hl = function(name, opts)
    vim.api.nvim_set_hl(0, name, opts)
end

-- Get set highlight groups from the current colorscheme to derive colors from
local hls = {
    normal = vim.api.nvim_get_hl(0, {
        name = "Normal",
    }),
    comment = vim.api.nvim_get_hl(0, {
        name = "Comment",
    }),
    string = vim.api.nvim_get_hl(0, {
        name = "String",
    }),
    pmenu = vim.api.nvim_get_hl(0, {
        name = "Pmenu",
    }),
}

-- Define colors
local colors = {
    -- Taken from https://github.com/nshern/neovim-default-colorscheme-extras/tree/main?tab=readme-ov-file
    palette = {
        ansi = {
            "#2c2e33",
            "#E5ADB9",
            "#A2DFC0",
            "#E3CA85",
            "#95C5E5",
            "#E5B6E6",
            "#7EDFDE",
            "#C4C6CD",
        },
        brights = {
            "#4f5258",
            "#FFC0B9",
            "#B4F6C0",
            "#FCE094",
            "#A6DBFF",
            "#FFCAFF",
            "#8CF8F7",
            "#9b9ea4",
        },
    },
    bg = {
        ---@diagnostic disable-next-line: undefined-field
        dark = darken(dec_to_hex(hls.normal.bg), vim.opt.background:get() == "dark" and 0.85 or 0.95),
        main = dec_to_hex(hls.normal.bg),
        light = lighten(dec_to_hex(hls.normal.bg), 0.75),
    },
    fg = {
        dark = darken(dec_to_hex(hls.comment.fg), 0.35),
        main = dec_to_hex(hls.normal.fg),
    },
    active = {
        bg = dec_to_hex(hls.string.fg),
        fg = dec_to_hex(hls.normal.bg),
    },
}

-- Override some highlight groups
hl("Pmenu", { fg = hls.pmenu.fg, bg = colors.bg.dark })
hl("NormalFloat", { link = "Pmenu" })
hl("FloatBorder", { link = "Pmenu" })
hl("EndOfBuffer", { fg = hls.normal.bg })
hl("WinSeparator", { fg = colors.fg.dark })
hl("Comment", { fg = hls.comment.fg, italic = true })

hl("YaziFloat", { link = "Pmenu" })

hl("FzfLuaNormal", { link = "Pmenu" })
hl("FzfLuaBorder", { link = "FzfLuaNormal" })

hl("NeoTreeNormal", { link = "Pmenu" })
hl("NeoTreeNormalNC", { link = "Pmenu" })

-- Lualine
local lualine_present = pcall(require, "lualine")
if lualine_present then
    require("lualine").setup({
        options = {
            theme = {
                normal = {
                    a = { bg = colors.active.bg, fg = colors.active.fg },
                    b = { bg = colors.bg.dark, fg = dec_to_hex(hls.normal.fg) },
                    c = { bg = colors.bg.main, fg = dec_to_hex(hls.normal.fg) },
                },
                insert = { a = { bg = colors.fg.light, fg = colors.bg.dark } },
                visual = { a = { bg = colors.fg.dark, fg = colors.bg.light } },
                replace = { a = { bg = colors.bg.dark, fg = colors.bg.light } },
                inactive = {
                    a = { bg = colors.bg.dark, fg = colors.fg.dark },
                    b = { bg = colors.bg.dark, fg = colors.fg.dark },
                    c = { bg = colors.bg.dark, fg = colors.fg.dark },
                },
            },
        },
    })
end

-- Set terminal colors for embedded terminals
vim.g.terminal_color_0 = colors.palette.ansi[1]
vim.g.terminal_color_1 = colors.palette.ansi[2]
vim.g.terminal_color_2 = colors.palette.ansi[3]
vim.g.terminal_color_3 = colors.palette.ansi[4]
vim.g.terminal_color_4 = colors.palette.ansi[5]
vim.g.terminal_color_5 = colors.palette.ansi[6]
vim.g.terminal_color_6 = colors.palette.ansi[7]
vim.g.terminal_color_7 = colors.palette.ansi[8]

vim.g.terminal_color_8 = colors.palette.brights[1]
vim.g.terminal_color_9 = colors.palette.brights[2]
vim.g.terminal_color_10 = colors.palette.brights[3]
vim.g.terminal_color_11 = colors.palette.brights[4]
vim.g.terminal_color_12 = colors.palette.brights[5]
vim.g.terminal_color_13 = colors.palette.brights[6]
vim.g.terminal_color_14 = colors.palette.brights[7]
vim.g.terminal_color_15 = colors.palette.brights[8]
