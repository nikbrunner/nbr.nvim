-- Install with: npm install -g @tailwindcss/language-server
-- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/tailwindcss.lua

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
        local configs = {
            "tailwind.config.js",
            "tailwind.config.cjs",
            "tailwind.config.mjs",
            "tailwind.config.ts",
            "tailwind.css",
        }

        local fname = vim.uri_to_fname(vim.uri_from_bufnr(bufnr))
        local match = vim.fs.find(configs, { upward = true, path = fname })[1]

        if match then
            cb(vim.fn.fnamemodify(match, ":h"))
        end
    end,
    settings = {
        tailwindCSS = {
            classAttributes = { "class", "className", "class:list", "classList", "ngClass" },
            classFunctions = { "clxs", "cn" },
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
