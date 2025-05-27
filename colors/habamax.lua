local lib = require("lib")

local set_hl = vim.api.nvim_set_hl

local hl_normal = lib.colors.get_hex_color("Normal")
local hl_comment = lib.colors.get_hex_color("Comment")
local darkend_normal_bg = lib.colors.darken(hl_normal.bg, 0.9, "#000000")
local pmenu_bg = darkend_normal_bg or hl_normal.bg

set_hl(0, "Pmenu", { fg = hl_normal.fg, bg = pmenu_bg }) -- Since many colorschemes derive their floating and darker elements from it, I manually override it.
set_hl(0, "EndOfBuffer", { fg = hl_normal.bg }) -- Hide the ~ at the end of the buffer
set_hl(0, "WinSeparator", { fg = hl_comment.fg, bg = hl_comment.bg })
set_hl(0, "VertSplit", { link = "WinSeparator" })
set_hl(0, "NormalFloat", { link = "Pmenu" })
set_hl(0, "FloatBorder", { link = "Pmenu" })
set_hl(0, "NeoTreeNormal", { link = "Pmenu" })
set_hl(0, "FzfLuaNormal", { link = "Pmenu" })
set_hl(0, "Comment", { fg = hl_comment.fg, italic = true })
set_hl(0, "NeoTreeNormal", { bg = darkend_normal_bg })
set_hl(0, "NeoTreeNormalNC", { link = "NeoTreeNormal" })
