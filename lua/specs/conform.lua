local prettier_cmd = "prettier"
local prettierd_cmd = "prettierd"
local prettier_configs = { ".prettierrc", ".prettierrc.json" }

local deno_cmd = "deno_fmt"
local deno_configs = { "deno.json", "deno.jsonc" }

---@type LazyPluginSpec
return {
    "stevearc/conform.nvim",
    ---@module "conform"
    event = { "BufReadPre", "BufNewFile" },
    cmd = { "ConformInfo" },
    init = function()
        vim.g.vin_autoformat_enabled = true
        vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

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

        local is_prettierd_available = conform.get_formatter_info(prettierd_cmd, bufnr).available
        local is_prettier_available = conform.get_formatter_info(prettier_cmd, bufnr).available
        local prettier_config = vim.fs.find(prettier_configs, { upward = true, path = fname })[1]

        if prettier_config ~= nil and not (is_prettierd_available or is_prettier_available) then
            vim.notify(
                string.format(
                    "There is a `prettier` config (%s), but `%s` or `%s` is not installed",
                    prettier_config,
                    prettierd_cmd,
                    prettier_cmd
                ),
                vim.log.levels.WARN,
                { title = "Conform" }
            )
            return
        elseif prettier_config ~= nil and (is_prettierd_available or is_prettier_available) then
            vim.notify(
                string.format(
                    "Found `prettier` config (%s), and will use `%s` for formatting",
                    prettier_config,
                    is_prettierd_available and prettierd_cmd or prettier_cmd
                ),
                vim.log.levels.WARN,
                { title = "Conform" }
            )
        end

        local is_deno_available = conform.get_formatter_info(deno_cmd, bufnr).available
        local deno_config = vim.fs.find(deno_configs, { upward = true, path = fname })[1]

        if deno_config and not is_deno_available then
            vim.notify("There is a deno config, but deno is not installed", vim.log.levels.WARN, { title = "Conform" })
            return
        elseif deno_config and is_deno_available then
            vim.notify(string.format("Using %s for formatting", deno_cmd), vim.log.levels.INFO, { title = "Conform" })
        end

        local function handle_prettier_or_deno()
            if deno_config ~= nil and is_deno_available then
                return { "deno_fmt", stop_after_first = true }
            elseif prettier_config ~= nil and is_prettierd_available or is_prettier_available then
                return { "prettierd", "prettier", stop_after_first = true }
            end
        end

        ---@type conform.setupOpts
        return {
            log_level = vim.log.levels.DEBUG,
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
