---@type LazyPluginSpec[]
return {
    {
        "black-atom-industries/nvim",
        name = "black-atom",
        dir = require("nbr.config").pathes.repos .. "/black-atom-industries/nvim",
        lazy = false,
        pin = true,
        priority = 1000,
        ---@module "black-atom"
        ---@type BlackAtom.Config
        opts = {
            theme = require("nbr.config").colorscheme,
            styles = {
                transparency = "none",
                cmp_kind_color_mode = "bg",
                diagnostics = {
                    background = true,
                },
            },
        },
    },
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        ---@module "tokyonight"
        ---@type tokyonight.Config
        opts = {
            on_highlights = function(highlights)
                highlights.YaziFloat = { link = "NormalFloat" }
            end,
        },
    },
}
