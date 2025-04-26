local M = {}

---@type LazyPluginSpec
M.spec = {
    "ariel-frischer/bmessages.nvim",
    lazy = false,
    keys = {
        {
            "<leader>am",
            "<CMD>Bmessagessp<CR>",
            desc = "[M]essages",
        },
    },
    opts = {},
}

return M.spec
