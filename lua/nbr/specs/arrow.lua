local M = {}

---@type LazyPluginSpec
M.spec = {
    "nikbrunner/arrow.nvim",
    event = "VimEnter",
    dir = require("nbr.config").pathes.repos .. "/nikbrunner/arrow.nvim",
    pin = true,
    opts = {
        leader_key = "M",
        buffer_leader_key = "m",
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
    keys = {
        {
            "<M-k>",
            function()
                require("arrow.persist").previous()
            end,
            desc = "Previous Bookmark",
        },
        {
            "<M-j>",
            function()
                require("arrow.persist").next()
            end,
            desc = "Next Bookmark",
        },
    },
}

return M.spec
