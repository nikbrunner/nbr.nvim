local M = {}

---@type LazyPluginSpec
M.spec = {
    "nikbrunner/arrow.nvim",
    -- STARTUP OPTIMIZATION: Changed from event = "VimEnter" to key-based loading
    -- This plugin was taking ~35ms on startup. Now it only loads when you use
    -- the keybindings (M, m, <M-k>, <M-j>), reducing startup time significantly.
    dir = require("lib.config").get_repo_path("nikbrunner/arrow.nvim"),
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
        { "M", desc = "Arrow bookmarks menu" },
        { "m", desc = "Arrow buffer bookmarks" },
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
