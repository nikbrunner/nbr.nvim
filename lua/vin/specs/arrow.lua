local M = {}

---@type LazyPluginSpec
M.spec = {
    "otavioschwanck/arrow.nvim",
    dependencies = {
        "WolfeCub/harpeek.nvim",
        keys = {
            {
                "<leader>M",
                function()
                    require("harpeek").toggle()
                end,
                desc = "[M]arks Preview",
            },
        },
        opts = {
            -- You can replace the hightlight group used on the currently selected buffer
            hl_group = "CursorLineNr",
            -- You can override any window options. For example here we set a different position & border.
            winopts = {
                title = "Bookmarks",
                row = 0.85,
                col = vim.o.columns,
                border = "solid",
            },
            format = "relative",
        },
        config = function(_, opts)
            require("harpeek").setup(opts)
        end,
    },
    keys = {
        {
            "<leader>m",
            function()
                require("arrow.ui").openMenu()
            end,
            desc = "Marks",
        },
    },
    opts = {
        leader_key = nil,
        show_icons = false,
        always_show_path = true,
        separate_by_branch = true,
        mappings = {
            edit = "e",
            delete_mode = "d",
            clear_all_items = "C",
            toggle = "a",
            open_vertical = "v",
            open_horizontal = "s",
            quit = "q",
        },
        window = {
            border = "solid",
        },
    },
}

return M.spec
