local icons = require("icons")

local Severity = vim.diagnostic.severity

vim.diagnostic.config({
    underline = false,
    virtual_text = {
        prefix = "●",
        spacing = 2,
        current_line = true,
    },
    virtual_lines = false,
    update_in_insert = false,
    float = {
        -- border = "solid",
        -- Show severity icons as prefixes.
        prefix = function(diag)
            local level = vim.diagnostic.severity[diag.severity]
            local prefix = string.format(" %s ", icons.diagnostics[level])
            return prefix, "Diagnostic" .. level:gsub("^%l", string.upper)
        end,
    },
    signs = {
        text = {
            [Severity.ERROR] = icons.diagnostics.Error,
            [Severity.WARN] = icons.diagnostics.Warn,
            [Severity.INFO] = icons.diagnostics.Info,
            [Severity.HINT] = icons.diagnostics.Hint,
        },
    },
})

-- Set up LSP servers.
vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
    once = true,
    callback = function()
        local server_configs = vim.iter(vim.api.nvim_get_runtime_file("lsp/*.lua", true))
            :map(function(file)
                return vim.fn.fnamemodify(file, ":t:r")
            end)
            :totable()
        vim.lsp.enable(server_configs)
    end,
})
