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

        delay = 0,

        ---@type (string|wk.Sorter)[]
        --- Mappings are sorted using configured sorters and natural sort of the keys
        --- Available sorters:
        --- * local: buffer-local mappings first
        --- * order: order of the items (Used by plugins like marks / registers)
        --- * group: groups last
        --- * alphanum: alpha-numerical first
        --- * mod: special modifier keys last
        --- * manual: the order the mappings were added
        --- * case: lower-case first
        sort = { "local", "order", "group", "case", "alphanum", "mod" },
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
                { "<leader>ah", icon = " " },
                { "<leader>ao", group = "[O]ptions", icon = "󰨚 " },
                { "<leader>as", group = "[S]ettings", icon = " " },
                { "<leader>ai", group = "[I]ntelligence", icon = "󰧑 " },
                { "<leader>aI", group = "[I]nfo", icon = "󰋽" },

                -- [W]orkspace
                { "<leader>w", group = "[W]orkspace", icon = "󰲃 " },
                { "<leader>wh", icon = " " },
                { "<leader>wv", group = "[V]ersion Control", icon = "󰋚 " },
                { "<leader>wS", group = "[S]ession", icon = " " },

                -- [D]ocument
                { "<leader>d", group = "[D]ocument", icon = "󱔘 " },
                { "<leader>dh", icon = " " },
                { "<leader>dv", group = "[V]ersion Control", icon = "󰋚 " },
                { "<leader>dy", group = "[Y]ank", icon = "󰆏 " },

                -- [H]unk
                { "<leader>c", group = "[C]ange", icon = " " },

                -- [S]ymbol
                { "s", group = "[S]ymbol", icon = " " },
                { "sc", group = "[C]alls", icon = "󰏻 " },
                { "sl", group = "[L]og", icon = " " },

                -- Others
                { "<leader>r", group = "[R]est Client", icon = "󰿘 " },
                { "<leader>n", group = "[N]otes", icon = " " },
            },
        },
    },
}
