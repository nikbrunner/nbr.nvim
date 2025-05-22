local M = {}

---@type LazyPluginSpec
M.spec = {
    "utilyre/barbecue.nvim",
    event = "BufReadPre",
    name = "barbecue",
    version = "*",
    dependencies = { "SmiteshP/nvim-navic" },
    opts = {
        ---Whether to attach navic to language servers automatically.
        ---
        ---@type boolean
        attach_navic = false,

        ---filetypes not to enable winbar in
        ---@type string[]
        exclude_filetypes = { "gitcommit", "ftterm_lazygit", ".luacheckrc" },

        ---whether to display path to file
        ---@type boolean
        show_dirname = true,

        ---whether to replace file icon with the modified symbol when buffer is modified
        ---@type boolean
        show_modified = true,

        ---Whether context text should follow its icon's color.
        ---@type boolean
        context_follow_icon_color = false,

        symbols = {
            modified = require("icons").git.modified,
            ellipsis = require("icons").misc.dots,
            separator = require("icons").misc.forwardSlash,
        },

        kinds = require("icons").kinds,
    },
    config = function(_, opts)
        require("barbecue").setup(opts)
    end,
}

return M.spec
