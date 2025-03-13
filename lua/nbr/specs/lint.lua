local M = {}

---@type LazyPluginSpec
M.spec = {
    "mfussenegger/nvim-lint",
    event = "BufRead",
    config = function()
        local lint = require("lint")

        vim.env.ESLINT_D_PPID = vim.fn.getpid()
        local eslint = "eslint_d"

        lint.linters_by_ft = {
            typescriptreact = { eslint },
            typescript = { eslint },
            javascript = { eslint },
            javascriptreact = { eslint },
        }

        vim.api.nvim_create_autocmd({ "BufWritePost" }, {
            callback = function()
                lint.try_lint()
            end,
        })
    end,
}

return M.spec
