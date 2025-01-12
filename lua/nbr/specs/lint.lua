local M = {}

---@type LazyPluginSpec
M.spec = {
    "mfussenegger/nvim-lint",
    event = "BufRead",
    config = function()
        local lint = require("lint")

        -- I was trying to set this up via `opts` but I have found no way to do it.
        lint.linters_by_ft = {
            typescriptreact = { "eslint" },
            typescript = { "eslint" },
            javascript = { "eslint" },
            javascriptreact = { "eslint" },
        }

        vim.api.nvim_create_autocmd({ "BufRead", "BufWritePost", "InsertLeave" }, {
            group = vim.api.nvim_create_augroup("vin_lint", { clear = true }),
            callback = function()
                pcall(require, "lint.try_lint")
            end,
        })
    end,
}

return M.spec
