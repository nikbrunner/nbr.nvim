WhichKeyIgnoreLabel = "which_key_ignore"

vim.g.mapleader = ","
vim.g.maplocalleader = "."

vim.opt.mouse = "a"

vim.opt.clipboard = "unnamedplus"

vim.opt.spelllang = "en_us,de_de"

vim.opt.cursorline = true
vim.opt.cursorcolumn = false

-- preview for substitution
vim.opt.inccommand = "split"

vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.smartindent = true

vim.o.winborder = "solid"

vim.o.conceallevel = 0

vim.o.foldenable = true
vim.o.foldlevel = 99
vim.o.foldmethod = "indent"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldtext = ""
vim.opt.foldcolumn = "0"
vim.opt.fillchars:append({ fold = " " })

vim.opt.wildmode = "longest:full,full"

vim.opt.jumpoptions = "stack"

vim.opt.fillchars = {
    foldopen = "",
    foldclose = "",
    fold = " ",
    foldsep = " ",
    diff = "╱",
}

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.autoread = true
vim.opt.backup = false
vim.opt.swapfile = false
vim.opt.writebackup = false
vim.opt.undofile = true
vim.opt.updatetime = 500

vim.opt.cmdheight = 1
vim.opt.pumheight = 30
vim.opt.pumblend = 10

vim.opt.showmode = false
vim.opt.laststatus = 3

vim.opt.wrap = false

vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"

vim.opt.guifont = { "JetBrainsMono Nerd Font", ":h16" }
-- vim.opt.guifont = { "Maple Mono NF", ":h16" }

vim.opt.scrolloff = 4

vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.signcolumn = "yes"

vim.opt.splitbelow = true
vim.opt.splitright = true

-- Abbreviations
vim.cmd("cabbrev Wqa wqa")
vim.cmd("cabbrev Wq wq")
vim.cmd("cabbrev Wa wa")

vim.filetype.add({
    http = "http",
    -- I only needed this because barbecue vomits if i vist this file, because it thinks its lua
    filename = {
        [".luacheckrc"] = ".luacheckrc",
    },
})

-- For terminals disable numbers and relative numbers
vim.api.nvim_create_autocmd("TermOpen", {
    group = vim.api.nvim_create_augroup("term-options", { clear = true }),
    callback = function()
        vim.opt.number = false
        vim.opt.relativenumber = false
        vim.opt.signcolumn = "no"
    end,
})
