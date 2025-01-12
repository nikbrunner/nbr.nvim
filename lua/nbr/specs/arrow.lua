local M = {}

-- TODO:  try out grapple instead
---@type LazyPluginSpec
M.spec = {
    "otavioschwanck/arrow.nvim",
    event = "VimEnter",
    opts = {
        leader_key = ";",
        buffer_leader_key = "gm",
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
