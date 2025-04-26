-- Install with: npm i -g bash-language-server
-- Also uses shellcheck for diagnostics and shfmt for formatting.
---@see https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#bashls

---@type vim.lsp.Config
return {
    cmd = { "bash-language-server", "start" },
    filetypes = { "bash", "sh", "zsh" },
}
