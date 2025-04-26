---@doc https://cmp.saghen.dev/
---@type LazyPluginSpec
return {
    "saghen/blink.cmp",
    lazy = false, -- lazy loading handled internally
    version = "v0.*",
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
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
        signature = {
            enabled = true,
        },
        completion = {
            list = {
                selection = {
                    preselect = false,
                    auto_insert = true,
                },
            },
            documentation = {
                auto_show = true,
                auto_show_delay_ms = 500,
            },
            menu = {
                border = "solid",
                winblend = 10,
                draw = {
                    columns = {
                        { "kind_icon", gap = 1 },
                        { "label", "label_description", gap = 1 },
                        { "kind", gap = 1 },
                        { "source_name" },
                    },
                    components = {
                        kind_icon = {
                            text = function(ctx)
                                local kind_icon, _, _ = require("mini.icons").get("lsp", ctx.kind)
                                return kind_icon
                            end,
                            highlight = function(ctx)
                                local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
                                return hl
                            end,
                        },
                        kind = {
                            highlight = function(ctx)
                                local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
                                return hl
                            end,
                        },
                    },
                },
            },
        },
        cmdline = {
            completion = {
                menu = {
                    auto_show = true,
                },
            },
        },
    },
}
