-- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/biome.lua

local filetypes = {
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
}

local biome_configs = {
    "biome.json",
    "biome.jsonc",
}

---@type vim.lsp.Config
return {
    cmd = { "biome", "lsp-proxy" },
    filetypes = filetypes,
    workspace_required = true,
    single_file_support = false,
    root_dir = function(bufnr, cb)
        local fname = vim.uri_to_fname(vim.uri_from_bufnr(bufnr))

        local biome_config = vim.fs.find(biome_configs, { upward = true, path = fname })[1]

        if biome_config then
            cb(vim.fn.fnamemodify(biome_config, ":h"))
        end
    end,
}
