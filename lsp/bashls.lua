-- Install with: npm i -g bash-language-server
--https://github.com/neovim/nvim-lspconfig/blob/master/lsp/bashls.lua

---@type vim.lsp.Config
return {
    cmd = { "bash-language-server", "start" },
    filetypes = { "bash", "sh", "zsh" },
}
