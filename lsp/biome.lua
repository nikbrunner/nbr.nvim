-- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/biome.lua

---@type vim.lsp.Config
return {
    cmd = { "biome", "lsp-proxy" },
    filetypes = {
        "astro",
        "css",
        "graphql",
        "html",
        "javascript",
        "javascriptreact",
        "json",
        "jsonc",
        "svelte",
        "typescript",
        "typescript.tsx",
        "typescriptreact",
        "vue",
    },
    workspace_required = true,
    single_file_support = false,
    root_dir = function(bufnr, cb)
        local configs = { "biome.json", "biome.jsonc" }
        local fname = vim.uri_to_fname(vim.uri_from_bufnr(bufnr))
        local match = vim.fs.find(configs, { upward = true, path = fname })[1]

        if match then
            cb(vim.fn.fnamemodify(match, ":h"))
        end
    end,
}
