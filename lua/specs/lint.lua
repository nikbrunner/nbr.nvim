---@type LazyPluginSpec
return {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function(_, opts)
        local lint = require("lint")
        local bufnr = vim.api.nvim_get_current_buf()
        local fname = vim.uri_to_fname(vim.uri_from_bufnr(bufnr))

        local eslint_cmd = "eslint"
        local eslint_configs = {
            ".eslintrc.js",
            ".eslintrc.cjs",
            ".eslintrc.json",
            ".eslintrc.yaml",
            "eslint.config.mjs",
            "eslint.config.js",
            "eslint.config.cjs",
            "eslint.config.json",
        }
        local has_eslint_config = vim.fs.find(eslint_configs, { upward = true, path = fname })[1]

        local deno_cmd = "deno"
        local deno_configs = { "deno.json", "deno.jsonc" }
        local has_deno_config = vim.fs.find(deno_configs, { upward = true, path = fname })[1]

        -- if has_eslint_config then
        --     vim.notify(string.format("Using %s for linting", eslint_cmd), vim.log.levels.INFO, { title = "Lint" })
        --
        --     vim.env.ESLINT_D_PPID = vim.fn.getpid()
        --     lint.linters_by_ft = {
        --         typescriptreact = { eslint_cmd },
        --         typescript = { eslint_cmd },
        --         javascript = { eslint_cmd },
        --         javascriptreact = { eslint_cmd },
        --     }
        -- end

        if has_deno_config then
            vim.notify(string.format("Using %s for linting", deno_cmd), vim.log.levels.INFO, { title = "Lint" })
            lint.linters_by_ft = {
                typescriptreact = { deno_cmd },
                typescript = { deno_cmd },
                javascript = { deno_cmd },
                javascriptreact = { deno_cmd },
            }
        end

        if not has_eslint_config and not has_deno_config then
            vim.notify("No eslint or deno config found", vim.log.levels.WARN, { title = "Lint" })
            return
        end

        vim.api.nvim_create_autocmd({ "BufWritePost" }, {
            group = vim.api.nvim_create_augroup("nbr.nvim_lint_on_save", {}),
            callback = function()
                pcall(lint.try_lint)
            end,
        })
    end,
}
