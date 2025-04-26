-- Install with: npm install -g @tailwindcss/language-server
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#tailwindcss

local tailwind_configs = {
    "tailwind.config.js",
    "tailwind.config.cjs",
    "tailwind.config.mjs",
    "tailwind.config.ts",
    "postcss.config.js",
    "postcss.config.cjs",
    "postcss.config.mjs",
    "postcss.config.ts",
}

---@type vim.lsp.Config
return {
    cmd = { "tailwindcss-language-server", "--stdio" },
    filetypes = {
        "astro",
        "html",
        "css",
        "less",
        "sass",
        "scss",
        "javascript",
        "javascriptreact",
        "rescript",
        "typescript",
        "typescriptreact",
        "vue",
        "svelte",
    },
    root_dir = function(bufnr, cb)
        local fname = vim.uri_to_fname(vim.uri_from_bufnr(bufnr))
        local tailwind_config = vim.fs.find(tailwind_configs, { upward = true, path = fname })[1]

        if tailwind_config then
            cb(vim.fn.fnamemodify(tailwind_config, ":h"))
        end
    end,
    settings = {
        tailwindCSS = {
            classAttributes = { "class", "className", "class:list", "classList", "ngClass" },
            lint = {
                cssConflict = "warning",
                invalidApply = "error",
                invalidConfigPath = "error",
                invalidScreen = "error",
                invalidTailwindDirective = "error",
                invalidVariant = "error",
                recommendedVariantOrder = "warning",
            },
            validate = true,
        },
    },
}
