---@type LazyPluginSpec
return {
    "saghen/blink.cmp",
    lazy = false, -- lazy loading handled internally
    version = "v0.*",
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
        enabled = function()
            return not vim.tbl_contains({ "snacks_picker_input" }, vim.bo.filetype)
        end,
        sources = {
            default = { "lazydev", "lsp", "path", "snippets", "buffer" },
            per_filetype = {
                codecompanion = { "codecompanion" },
            },
            providers = {
                lazydev = {
                    name = "LazyDev",
                    module = "lazydev.integrations.blink",
                    -- make lazydev completions top priority (see `:h blink.cmp`)
                    score_offset = 100,
                },
            },
        },
        signature = { enabled = true },
        cmdline = {
            keymap = {
                preset = "default",
            },
            completion = {

                menu = {
                    auto_show = true,
                },
            },
        },
        completion = {
            list = {
                -- Controls how the completion items are selected
                -- 'preselect' will automatically select the first item in the completion list
                -- 'manual' will not select any item by default
                -- 'auto_insert' will not select any item by default, and insert the completion items automatically when selecting them
                selection = { preselect = false, auto_insert = true },
            },

            menu = {
                border = "solid",
                winblend = 10,
                -- Whether to automatically show the window when new completion items are available
                auto_show = true,
                -- Controls how the completion items are rendered on the popup window
                draw = {
                    -- Aligns the keyword you've typed to a component in the menu
                    align_to = "label", -- or 'none' to disable
                    -- Left and right padding, optionally { left, right } for different padding on each side
                    padding = 2,
                    -- Gap between columns
                    gap = 2,
                    -- Components to render, grouped by column
                    columns = { { "kind_icon" }, { "label", "label_description", gap = 1 } },
                    -- for a setup similar to nvim-cmp: https://github.com/Saghen/blink.cmp/pull/245#issuecomment-2463659508
                    -- columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind" } },
                },
            },
        },
    },
}
