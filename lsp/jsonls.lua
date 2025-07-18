-- Install with: npm i -g vscode-langservers-extracted
-- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/jsonls.lua

---@type vim.lsp.Config
return {
    cmd = { "vscode-json-language-server", "--stdio" },
    filetypes = { "json", "jsonc" },
    settings = {
        json = {
            validate = { enable = true },
            schemas = require("schemastore").json.schemas(),
        },
    },
}
