local State = require("nbr.state")

local M = {}

---@type LazyPluginSpec
M.spec = {
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
    ---@type conform.setupOpts
    opts = {
        format_on_save = function()
            if vim.g.vin_autoformat_enabled then
                return { timeout_ms = 500, lsp_fallback = true }
            end
        end,
        formatters_by_ft = {
            css = { "prettier" },
            scss = { "prettier" },
            graphql = { "prettier" },
            html = { "prettier" },
            javascript = { "prettier" },
            javascriptreact = { "prettier" },
            json = function()
                return State:get("is_deno_project") and { "deno_fmt" } or { "prettier" }
            end,
            lua = { "stylua" },
            markdown = { "prettier" },
            svelte = { "prettier" },
            typescript = function()
                return State:get("is_deno_project") and { "deno_fmt" } or { "prettier" }
            end,
            typescriptreact = { "prettier" },
            yaml = { "prettier" },
            toml = { "taplo" },
            go = { "gofmt" },
            sh = { "shfmt" },
            http = { "kulala-fmt" },
            -- c = { "clang-format" },
        },
    },
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
            "<leader>aIf",
            "<cmd>ConformInfo<CR>",
            desc = "[F]ormatter",
        },
    },
}

return M.spec
