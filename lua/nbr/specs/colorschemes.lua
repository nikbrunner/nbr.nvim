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

    {
        "projekt0n/github-nvim-theme",
        lazy = false,
        priority = 1000,
        ---@type GhTheme.Config
        opts = {
            options = {
                hide_end_of_buffer = true,
                styles = {
                    comments = "italic",
                },
                darken = {
                    floats = true,
                    sidebars = {
                        enable = true,
                    },
                },
            },
            groups = {
                all = {
                    FzfLuaNormal = { bg = "bg0" },
                    FzfLuaBorder = { bg = "bg0" },
                    NormalFloat = { bg = "bg0" },
                    FloatTitle = { bg = "bg0" },
                    FloatBorder = { bg = "bg0" },
                },
            },
        },
        config = function(_, opts)
            require("github-theme").setup(opts)
        end,
    },

    {
        "rose-pine/neovim",
        name = "rose-pine",
        lazy = false,
        priority = 1000,
        opts = {
            highlight_groups = {
                EndOfBuffer = { fg = "surface" },
            },
        },
    },
}
