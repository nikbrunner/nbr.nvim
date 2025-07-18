-- Install with:
-- mac: brew install lua-language-server
-- Arch: pacman -S lua-language-server
-- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/lua_ls.lua

---@type vim.lsp.Config
return {
    cmd = { "lua-language-server" },
    filetypes = { "lua" },
    root_markers = { ".luarc.json", ".luarc.jsonc" },
    settings = {
        Lua = {
            -- Using stylua for formatting.
            format = { enable = false },
            hint = {
                enable = true,
                arrayIndex = "Disable",
            },
            runtime = {
                version = "LuaJIT",
            },
            workspace = {
                checkThirdParty = false,
                library = {
                    vim.env.VIMRUNTIME,
                    "${3rd}/luv/library",
                },
            },
            completion = { callSnippet = "Replace" },
            codeLens = { enable = true },
        },
    },
}
