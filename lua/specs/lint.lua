local M = {}

---@type LazyPluginSpec
M.spec = {
    "mfussenegger/nvim-lint",
    event = "BufRead",
    -- Config and setup is called inside of lsp.lua file
}

return M.spec
