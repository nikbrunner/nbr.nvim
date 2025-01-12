local M = {}

---@type LazyPluginSpec
M.spec = {
    "folke/ts-comments.nvim",
    opts = {},
    event = "VeryLazy",
    enabled = vim.fn.has("nvim-0.10.0") == 1,
}

return M.spec
