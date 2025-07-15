---TODO: Fix the the +Prev ftFT text before the key bread crumbs

---@module "which-key"
---@type LazyPluginSpec
return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    ---@type wk.Opts
    opts = {
        preset = "helix",
        win = {
            title = "nbr.nvim",
            border = "solid",
            padding = { 1, 4 },
            wo = {
                winblend = 10,
            },
        },

        delay = 150,

        layout = {
            spacing = 5, -- spacing between columns
        },

        icons = {
            mappings = true, -- Disable all icons
            separator = "", -- symbol used between a key and it's label
            rules = {
                { plugin = "yazi.nvim", icon = " " },
                { plugin = "file-surfer.nvim", icon = " " },
                { plugin = "gitpad.nvim", icon = "󰠮 " },
                { plugin = "no-neck-pain.nvim", icon = "󰈈 " },
                { plugin = "supermaven-nvim", icon = "󰧑 " },
            },
        },

        show_help = false, -- show a help message in the command line for using WhichKey
        show_keys = false, -- show the currently pressed key and its label as a message in the command line

        ---@type wk.Spec
        spec = {
            {
                mode = { "n", "v" },

                { "<leader>,", icon = " " },

                -- [A]pp
                { "<leader>a", group = "[A]pp", icon = " " },
                { "<leader>ag", icon = " " },
                { "<leader>ao", group = "[O]ptions", icon = "󰨚 " },
                { "<leader>as", group = "[S]ettings", icon = " " },
                { "<leader>ai", group = "[I]ntelligence", icon = "󰧑 " },
                { "<leader>ah", group = "[H]elp", icon = " " },
                { "<leader>al", group = "[L]anguages", icon = "󰛦 " },

                -- [W]orkspace
                { "<leader>w", group = "[W]orkspace", icon = "󰲃 " },
                { "<leader>wg", icon = " " },
                { "<leader>wv", group = "[V]ersion Control", icon = "󰋚 " },
                { "<leader>wS", group = "[S]ession", icon = " " },

                -- [D]ocument
                { "<leader>d", group = "[D]ocument", icon = "󱔘 " },
                { "<leader>dg", icon = " " },
                { "<leader>dv", group = "[V]ersion Control", icon = "󰋚 " },
                { "<leader>dy", group = "[Y]ank", icon = "󰆏 " },

                { "<localleader>d", group = "[D]aily Notes", icon = "󰃵 " },
                { "<localleader>i", group = "[I]nsert", icon = "⎀ " },

                -- [H]unk
                { "<leader>c", group = "[C]hange", icon = " " },

                -- [S]ymbol
                { "s", group = "[S]ymbol", icon = " " },
                { "sg", icon = " " },
                { "sc", group = "[C]alls", icon = "󰏻 " },
                { "sl", group = "[L]og", icon = " " },

                -- Others
                { "<leader>r", group = "[R]est Client", icon = "󰿘 " },
                { "<leader>n", group = "[N]otes", icon = " " },
                { "<leader>nd", group = "[D]ailies", icon = "  " },
                { "<leader>ng", group = "[G]it Notes", icon = "󰠮 " },
                { "<leader>ni", group = "[I]nsert", icon = "⎀ " },
            },
        },
    },
}
