-- Install with: npm i -g vscode-langservers-extracted
-- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/cssls.lua

---@type vim.lsp.Config
return {
    cmd = { "vscode-css-language-server", "--stdio" },
    filetypes = { "css", "scss", "less" },
    settings = {
        css = { validate = true },
        scss = { validate = true },
        less = { validate = true },
    },
}
