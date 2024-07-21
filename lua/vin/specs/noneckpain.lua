local M = {}

---@type LazyPluginSpec
M.spec = {
    "shortcuts/no-neck-pain.nvim",
    event = "VeryLazy",
    keys = {
        { "<leader>z", "<CMD>NoNeckPain<CR>", desc = "[Z]en" },
    },
    opts = {
        width = 165,
    },
}

return M.spec
