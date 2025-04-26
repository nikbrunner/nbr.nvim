---@see https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#gopls

---@type vim.lsp.Config
return {
    cmd = { "gopls" },
    filetypes = { "go", "gomod", "gowork", "gotmpl" },
}
