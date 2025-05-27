local M = {}

---@type LazyPluginSpec[]
M.specs = {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        branch = "master",
        event = { "VeryLazy" },
        opts = {
            highlight = {
                enable = true,
                ---@diagnostic disable-next-line: unused-local
                disable = function(lang, bufnr)
                    return vim.api.nvim_buf_line_count(bufnr) > 5000
                end,
                additional_vim_regex_highlighting = { "markdown" },
            },
            indent = {
                enable = false,
            },
            auto_install = true,
            ensure_installed = {
                "bash",
                "c",
                "css",
                "go",
                "html",
                "javascript",
                "json",
                "lua",
                "markdown",
                "markdown_inline",
                "rust",
                "toml",
                "astro",
                "typescript",
                "vim",
                "vimdoc",
                "yaml",
                "http",
            },
            incremental_selection = {
                enable = true,
                disable = { "vim", "qf" },
                keymaps = {
                    init_selection = "vv",
                    node_incremental = "v",
                    node_decremental = "<BS>",
                },
            },
            textobjects = {
                move = {
                    enable = true,
                    set_jumps = true, -- whether to set jumps in the jumplist
                    goto_next_start = {
                        ["]f"] = { query = "@call.outer", desc = "Next function call start" },
                        ["]m"] = { query = "@function.outer", desc = "Next method/function def start" },
                        ["]c"] = { query = "@class.outer", desc = "Next class start" },
                        ["]i"] = { query = "@conditional.outer", desc = "Next conditional start" },
                        ["]l"] = { query = "@loop.outer", desc = "Next loop start" },

                        -- You can pass a query group to use query from `queries/<lang>/<query_group>.scm file in your runtime path.
                        -- Below example nvim-treesitter's `locals.scm` and `folds.scm`. They also provide highlights.scm and indent.scm.
                        ["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
                    },
                    goto_next_end = {
                        ["]F"] = { query = "@call.outer", desc = "Next function call end" },
                        ["]M"] = { query = "@function.outer", desc = "Next method/function def end" },
                        ["]C"] = { query = "@class.outer", desc = "Next class end" },
                        ["]I"] = { query = "@conditional.outer", desc = "Next conditional end" },
                        ["]L"] = { query = "@loop.outer", desc = "Next loop end" },
                    },
                    goto_previous_start = {
                        ["[f"] = { query = "@call.outer", desc = "Prev function call start" },
                        ["[m"] = { query = "@function.outer", desc = "Prev method/function def start" },
                        ["[c"] = { query = "@class.outer", desc = "Prev class start" },
                        ["[i"] = { query = "@conditional.outer", desc = "Prev conditional start" },
                        ["[l"] = { query = "@loop.outer", desc = "Prev loop start" },
                    },
                    goto_previous_end = {
                        ["[F"] = { query = "@call.outer", desc = "Prev function call end" },
                        ["[M"] = { query = "@function.outer", desc = "Prev method/function def end" },
                        ["[C"] = { query = "@class.outer", desc = "Prev class end" },
                        ["[I"] = { query = "@conditional.outer", desc = "Prev conditional end" },
                        ["[L"] = { query = "@loop.outer", desc = "Prev loop end" },
                    },
                },
            },
        },
        config = function(_, opts)
            local configs = require("nvim-treesitter.configs")

            configs.setup(opts)
        end,
    },

    {
        "nvim-treesitter/nvim-treesitter-context",
        dependencies = "nvim-treesitter/nvim-treesitter",
        event = "VeryLazy",
        ---@type TSContext.Config
        ---@diagnostic disable-next-line: missing-fields
        opts = {
            line_numbers = true,
            enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
            max_lines = 6, -- How many lines the window should span. Values <= 0 mean no limit.
            multiline_threshold = 20, -- Maximum number of lines to show for a single context
            trim_scope = "outer", -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
            zindex = 20, -- The Z-index of the context window
            mode = "cursor", -- Line used to calculate context. Choices: 'cursor', 'topline'
            on_attach = function(bufnr)
                local disabled_filetypes = { "markdown", "vim" }
                local line_count = vim.api.nvim_buf_line_count(bufnr)
                local should_not_attach = vim.list_contains(disabled_filetypes, vim.bo[bufnr].filetype) or line_count > 5000
                return not should_not_attach
            end,
            patterns = {
                default = {
                    "class",
                    "function",
                    "method",
                    "for", -- These won't appear in the context
                    "while",
                    "if",
                    "switch",
                    "case",
                    "const",
                },
            },
        },
        config = function(_, opts)
            local context = require("treesitter-context")
            context.setup(opts)
        end,
    },

    {
        "windwp/nvim-ts-autotag",
        event = "BufReadPre",
        opts = {},
    },

    {
        "wurli/contextindent.nvim",
        opts = { pattern = "*" },
        event = "BufRead",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
    },
}

return M.specs
