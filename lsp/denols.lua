-- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/denols.lua

---@type vim.lsp.Config
return {
    cmd = { "deno", "lsp" },
    cmd_env = { NO_COLOR = true },
    filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
    root_dir = function(bufnr, cb)
        local configs = { "deno.json", "deno.jsonc" }

        local fname = vim.uri_to_fname(vim.uri_from_bufnr(bufnr))
        local match = vim.fs.find(configs, { upward = true, path = fname })[1]

        if match then
            cb(vim.fn.fnamemodify(match, ":h"))
        end
    end,

    ---@diagnostic disable-next-line: unused-local
    before_init = function(params)
        vim.g.markdown_fenced_languages = {
            "ts=typescript",
        }
    end,

    on_attach = function()
        vim.notify("Attached to Deno LSP", vim.log.levels.INFO, { title = "Deno LSP" })
    end,

    -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#denols
    settings = {
        deno = {
            enable = true,
            suggest = {
                imports = {
                    hosts = {
                        ["https://deno.land"] = true,
                    },
                },
            },
        },
    },
}
