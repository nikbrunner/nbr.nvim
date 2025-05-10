local ShaDa = require("shada")

---@type LazyPluginSpec[]
return {
    {
        "f-person/auto-dark-mode.nvim",
        lazy = false,
        priority = 10000,
        opts = {
            set_dark_mode = function()
                vim.cmd.colorscheme(ShaDa.read("colorscheme_dark"))
                ShaDa.update("background", "dark")
            end,
            set_light_mode = function()
                vim.cmd.colorscheme(ShaDa.read("colorscheme_light"))
                ShaDa.update("background", "light")
            end,
            fallback = ShaDa.read("background"),
            update_interval = 25,
        },
    },

    {
        "black-atom-industries/nvim",
        name = "black-atom",
        dir = require("lib.config").get_repo_path("black-atom-industries/nvim"),
        lazy = false,
        priority = 1000,
        ---@module "black-atom"
        ---@type BlackAtom.Config
        opts = {
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
