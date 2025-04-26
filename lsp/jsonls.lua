-- Install with: npm i -g vscode-langservers-extracted
---@see https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#jsonls

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
