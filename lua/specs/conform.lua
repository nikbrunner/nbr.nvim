---@type LazyPluginSpec
return {
    "stevearc/conform.nvim",
    ---@module "conform"
    event = { "BufReadPre", "BufNewFile" },
    cmd = { "ConformInfo" },
    init = function()
        vim.g.vin_autoformat_enabled = true

        -- Assign `http` files as `http` files (currently they are interpreted as `conf`)
        vim.filetype.add({
            extension = {
                http = "http",
            },
        })
    end,
    opts = function()
        local conform = require("conform")
        local bufnr = vim.api.nvim_get_current_buf()
        local fname = vim.uri_to_fname(vim.uri_from_bufnr(bufnr))

        local prettier_cmd = "prettier"
        local prettier_configs = { ".prettierrc", ".prettierrc.json" }
        local is_prettier_available = conform.get_formatter_info(prettier_cmd, bufnr).available
        local has_prettier_config = vim.fs.find(prettier_configs, { upward = true, path = fname })[1]

        if has_prettier_config and not is_prettier_available then
            vim.notify(
                "There is a prettier config, but prettier is not installed",
                vim.log.levels.WARN,
                { title = "Conform" }
            )
            return
        elseif has_prettier_config and is_prettier_available then
            vim.notify(string.format("Using %s for formatting", prettier_cmd), vim.log.levels.INFO, { title = "Conform" })
        end

        local deno_cmd = "deno_fmt"
        local deno_configs = { "deno.json", "deno.jsonc" }
        local is_deno_available = conform.get_formatter_info(deno_cmd, bufnr).available
        local has_deno_config = vim.fs.find(deno_configs, { upward = true, path = fname })[1]

        if has_deno_config and not is_deno_available then
            vim.notify("There is a deno config, but deno is not installed", vim.log.levels.WARN, { title = "Conform" })
            return
        elseif has_deno_config and is_deno_available then
            vim.notify(string.format("Using %s for formatting", deno_cmd), vim.log.levels.INFO, { title = "Conform" })
        end

        local function handle_prettier_or_deno()
            return has_deno_config and { "deno_fmt" } or has_prettier_config and { "prettier" } or {}
        end

        ---@type conform.setupOpts
        return {
            format_on_save = function()
                if vim.g.vin_autoformat_enabled then
                    return { timeout_ms = 500, lsp_fallback = "fallback" }
                end
            end,
            formatters_by_ft = {
                javascript = handle_prettier_or_deno,
                javascriptreact = handle_prettier_or_deno,
                markdown = handle_prettier_or_deno,
                json = handle_prettier_or_deno,
                typescript = handle_prettier_or_deno,
                typescriptreact = handle_prettier_or_deno,
                css = { "prettier" },
                scss = { "prettier" },
                graphql = { "prettier" },
                html = { "prettier" },
                lua = { "stylua" },
                svelte = { "prettier" },
                yaml = { "prettier" },
                toml = { "taplo" },
                go = { "gofmt" },
                sh = { "shfmt" },
                http = { "kulala-fmt" },
            },
        }
    end,
    keys = {
        {
            "gq",
            mode = { "n", "x" },
            function()
                require("conform").format({
                    async = true,
                    timeout_ms = 500,
                    lsp_fallback = true,
                })
            end,
            desc = "Format",
        },
        {
            "<leader>aof",
            function()
                if vim.g.vin_autoformat_enabled then
                    vim.g.vin_autoformat_enabled = false
                else
                    vim.g.vin_autoformat_enabled = true
                end

                if vim.g.vin_autoformat_enabled then
                    vim.notify("Autoformat enabled", vim.log.levels.INFO, { title = "Conform" })
                else
                    vim.notify("Autoformat disabled", vim.log.levels.INFO, { title = "Conform" })
                end
            end,
            desc = "Toggle Format on Save",
        },
        {
            "<leader>ahf",
            "<cmd>ConformInfo<CR>",
            desc = "[F]ormatter",
        },
    },
}
