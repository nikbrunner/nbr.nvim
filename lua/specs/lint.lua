---@type LazyPluginSpec
return {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local lint = require("lint")

        -- Helper function to determine which linter to use based on config files
        local function get_linter_for_buffer(bufnr)
            local fname = vim.api.nvim_buf_get_name(bufnr)
            if fname == "" then
                return nil
            end

            -- Check for Biome config first (highest priority)
            -- local biome_configs = { "biome.json", "biome.jsonc" }
            -- local biome_config = vim.fs.find(biome_configs, { upward = true, path = fname })[1]
            -- if biome_config then
            --     return "biomejs"
            -- end

            -- Check for Deno config
            local deno_configs = { "deno.json", "deno.jsonc" }
            local deno_config = vim.fs.find(deno_configs, { upward = true, path = fname })[1]
            if deno_config then
                return "deno"
            end

            -- Check for ESLint config (lowest priority)
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
            local eslint_config = vim.fs.find(eslint_configs, { upward = true, path = fname })[1]
            if eslint_config then
                vim.env.ESLINT_D_PPID = vim.fn.getpid()
                return "eslint"
            end

            return nil
        end

        -- Set up linters by file type dynamically
        local function setup_linters()
            local bufnr = vim.api.nvim_get_current_buf()
            local linter = get_linter_for_buffer(bufnr)

            if linter then
                local ft = vim.bo[bufnr].filetype
                local supported_filetypes = {
                    javascript = true,
                    javascriptreact = true,
                    typescript = true,
                    typescriptreact = true,
                    json = true,
                    jsonc = true,
                }

                if supported_filetypes[ft] then
                    lint.linters_by_ft[ft] = { linter }
                    vim.notify(
                        string.format("Using %s for linting %s files", linter, ft),
                        vim.log.levels.INFO,
                        { title = "Lint" }
                    )
                end
            end
        end

        local lint_group = vim.api.nvim_create_augroup("nbr.nvim_lint", { clear = true })

        vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter" }, {
            group = lint_group,
            callback = function()
                setup_linters()
                pcall(lint.try_lint)
            end,
        })
    end,
}
