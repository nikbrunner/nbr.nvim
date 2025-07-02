vim.opt_local.wrap = true
vim.opt_local.linebreak = true

-- Detect printwidth from .prettierrc or .editorconfig, fallback to 80
local detected_width = require("lib.files").detect_printwidth()
vim.opt_local.textwidth = detected_width or 0

vim.opt_local.formatoptions:append("t") -- Auto-wrap text using textwidth
vim.opt_local.formatoptions:remove("l") -- Allow wrapping of long lines in insert mode

local map = vim.keymap.set

map({ "n", "o", "x" }, "j", "gj", {})
map({ "n", "o", "x" }, "k", "gk", {})
map({ "n", "o", "x" }, "0", "g0", {})
map({ "n", "o", "x" }, "$", "g$", {})
