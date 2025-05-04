---@doc https://cmp.saghen.dev/
---@type LazyPluginSpec
return {
    "saghen/blink.cmp",
    event = "InsertEnter",
    version = "v0.*",
    dependencies = {
        "L3MON4D3/LuaSnip",
        dependencies = { "rafamadriz/friendly-snippets" },
        opts = {},
        config = function(_, opts)
            local luasnip = require("luasnip")

            luasnip.setup(opts)

            require("luasnip.loaders.from_vscode").lazy_load()

            -- Use <C-c> to select a choice in a snippet.
            vim.keymap.set({ "i", "s" }, "<C-c>", function()
                if luasnip.choice_active() then
                    require("luasnip.extras.select_choice")()
                end
            end, { desc = "Select choice" })
        end,
    },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
        keymap = {
            preset = "default",
        },
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
        -- snippets = { preset = "luasnip" },
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
            accept = {
                auto_brackets = {
                    enabled = false,
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
            keymap = {
                preset = "default",
            },
            completion = {
                menu = {
                    auto_show = true,
                },
            },
        },
    },
    config = function(_, opts)
        require("blink.cmp").setup(opts)

        vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities(nil, true) })
    end,
}
