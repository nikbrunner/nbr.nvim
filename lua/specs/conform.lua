local prettier_cmd = "prettierd"
local prettier_configs = { ".prettierrc", ".prettierrc.json" }

local deno_cmd = "deno_fmt"
local deno_configs = { "deno.json", "deno.jsonc" }

-- https://github.com/kiyoon/conform.nvim/blob/f73ca2e94221d0374134b64c085d1847a6ed3593/lua/conform/formatters/biome.lua
local biome_cmd = "biome"
local biome_configs = { "biome.json", "biome.jsonc" }

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

        local is_prettier_available = conform.get_formatter_info(prettier_cmd, bufnr).available
        local prettier_config = vim.fs.find(prettier_configs, { upward = true, path = fname })[1]

        if prettier_config ~= nil then
            if not is_prettier_available then
                vim.notify(
                    string.format(
                        "There is a `prettier` config (%s), but `%s` is not installed",
                        prettier_config,
                        prettier_cmd
                    ),
                    vim.log.levels.WARN,
                    { title = "Conform" }
                )
            else
                vim.notify(
                    string.format(
                        "Found `prettier` config (%s), and will use `%s` for formatting",
                        prettier_config,
                        prettier_cmd
                    ),
                    vim.log.levels.INFO,
                    { title = "Conform" }
                )
            end
        end

        local is_deno_available = conform.get_formatter_info(deno_cmd, bufnr).available
        local deno_config = vim.fs.find(deno_configs, { upward = true, path = fname })[1]

        if deno_config ~= nil then
            if not is_deno_available then
                vim.notify("There is a deno config, but deno is not installed", vim.log.levels.WARN, { title = "Conform" })
            else
                vim.notify(string.format("Using %s for formatting", deno_cmd), vim.log.levels.INFO, { title = "Conform" })
            end
        end

        local is_biome_available = conform.get_formatter_info(biome_cmd, bufnr).available
        local biome_config = vim.fs.find(biome_configs, { upward = true, path = fname })[1]

        if biome_config ~= nil then
            if not is_biome_available then
                vim.notify("There is a biome config, but biome is not installed", vim.log.levels.WARN, { title = "Conform" })
            else
                vim.notify(string.format("Using %s for formatting", biome_cmd), vim.log.levels.INFO, { title = "Conform" })
            end
        end

        local function handle_shared_formatter()
            -- NOTE: The `biome-check` command combines the `biome` and `biome-organize-imports` commands
            -- https://github.com/kiyoon/conform.nvim/blob/f73ca2e94221d0374134b64c085d1847a6ed3593/lua/conform/formatters/biome-check.lua
            -- https://github.com/kiyoon/conform.nvim/blob/f73ca2e94221d0374134b64c085d1847a6ed3593/lua/conform/formatters/biome.lua
            -- https://github.com/kiyoon/conform.nvim/blob/f73ca2e94221d0374134b64c085d1847a6ed3593/lua/conform/formatters/biome-organize-imports.lua

            if biome_config ~= nil and is_biome_available then
                -- return { "biome", "biome-organize-imports" }
                return { "biome-check" }
            end

            if deno_config ~= nil and is_deno_available then
                return { "deno_fmt", stop_after_first = true }
            end

            if prettier_config ~= nil and is_prettier_available then
                return { prettier_cmd, stop_after_first = true }
            end

            return {}
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
                javascript = handle_shared_formatter,
                javascriptreact = handle_shared_formatter,
                markdown = handle_shared_formatter,
                json = handle_shared_formatter,
                typescript = handle_shared_formatter,
                typescriptreact = handle_shared_formatter,
                css = { prettier_cmd },
                scss = { prettier_cmd },
                graphql = { prettier_cmd },
                html = { prettier_cmd },
                lua = { "stylua" },
                svelte = { prettier_cmd },
                yaml = { prettier_cmd },
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
