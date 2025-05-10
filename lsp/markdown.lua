-- Install with
-- mac: brew install marksman
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#lua_ls

---@type vim.lsp.Config
return {
    cmd = { "marksman", "server" },
    filetypes = { "markdown", "markdown.mdx" },
    root_markers = { ".marksman.toml", ".git" },
    settings = {},
}
