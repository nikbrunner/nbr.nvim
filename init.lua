local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end

vim.opt.rtp:prepend(lazypath)

require("config")
require("options")
require("lib")
require("keymaps")
require("autocmd")
require("neovide")
require("lsp")

require("lazy").setup("specs", {
    defaults = {
        lazy = true,
    },
    performance = {
        rtp = {
            disabled_plugins = {
                "gzip",
                "netrwPlugin",
                "rplugin",
                "tarPlugin",
                "tohtml",
                "tutor",
                "zipPlugin",
            },
        },
    },
    checker = {
        enabled = true,
        notify = false,
    },
    rocks = {
        enabled = false,
    },
    change_detection = {
        notify = false,
    },
    ui = {
        size = { width = 0.8, height = 0.8 },
        border = "solid",
    },
})
