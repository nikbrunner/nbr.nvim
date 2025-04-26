local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

---@diagnostic disable-next-line: undefined-field
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end

---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- https://github.com/neovim/neovim/issues/31675#issuecomment-2558405042
vim.hl = vim.highlight

require("config")
require("options")
require("lib")
require("keymaps")
require("autocmd")
require("neovide")

require("lazy").setup(
    "specs",
    ---@module "lazy"
    ---@type LazyConfig
    {
        defaults = {
            lazy = true, -- should plugins be lazy-loaded?
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
    }
)
