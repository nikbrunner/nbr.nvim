---@diagnostic disable: missing-fields

local Config = require("config")
local date_format = "%Y.%m.%d - %A"

---@type LazyPluginSpec[]
return {
    {
        "obsidian-nvim/obsidian.nvim",
        version = "*", -- recommended, use latest release instead of latest commit
        ft = "markdown",
        lazy = false,
        event = {
            "DirChanged " .. Config.pathes.notes.personal,
            "DirChanged " .. Config.pathes.notes.work.dcd,
            "BufReadPre " .. Config.pathes.notes.personal .. "/*.md",
            "BufReadPre " .. Config.pathes.notes.work.dcd .. "/*.md",
        },
        dependencies = {
            -- Required.
            "nvim-lua/plenary.nvim",
            "folke/snacks.nvim",
        },
        ---@module 'obsidian'
        ---@type obsidian.config.ClientOpts
        opts = {
            workspaces = {
                {
                    name = "personal",
                    path = "~/repos/nikbrunner/notes",
                    overrides = {
                        daily_notes = {
                            folder = "02 - Areas/Log/2025/05-May",
                            date_format = date_format,
                            default_tags = { "log" },
                            template = "05 - Meta/Templates/Daily Note.md",
                            workdays_only = false,
                        },
                        templates = {
                            folder = "05 - Meta/Templates/",
                            date_format = date_format,
                            -- A map for custom variables, the key should be the variable and the value a function
                            substitutions = {},
                        },
                    },
                },
                {
                    name = "dcd",
                    path = "~/repos/nikbrunner/dcd-notes",
                    overrides = {
                        daily_notes = {
                            folder = "Log/2025",
                            date_format = date_format,
                            default_tags = { "log" },
                            template = "Templates/Daily Note.md",
                            workdays_only = true,
                        },
                        templates = {
                            folder = "Templates",
                            date_format = date_format,
                            -- A map for custom variables, the key should be the variable and the value a function
                            substitutions = {},
                        },
                    },
                },
            },

            mappings = {
                -- Overrides the 'gf' mapping to work on markdown/wiki links within your vault.
                ["gf"] = {
                    action = function()
                        return require("obsidian").util.gf_passthrough()
                    end,
                    opts = { noremap = false, expr = true, buffer = true },
                },
                -- Disable this mapping
                -- ["<C-t>"] = {
                --     action = function()
                --         return require("obsidian").util.toggle_checkbox()
                --     end,
                --     opts = { buffer = true },
                -- },
                -- Smart action depending on context: follow link, show notes with tag, toggle checkbox, or toggle heading fold
                ["<cr>"] = {
                    action = function()
                        return require("obsidian").util.smart_action()
                    end,
                    opts = { buffer = true, expr = true },
                },
            },

            completion = {
                nvim_cmp = false,
                blink = true,
                min_chars = 0,
            },
            ui = {
                enable = true, -- markview.nvim does that
            },
        },
        keys = function()
            local map = function(map, subcmd, desc)
                return {
                    "<localleader>" .. map,
                    "<cmd>Obsidian " .. subcmd .. "<cr>",
                    desc = desc,
                }
            end

            return {
                map("<localleader>", "quick_switch", "Quick Switch"),
                map("f", "search", "Find"),
                -- map("ix", "toggle_checkbox", "Checkbox"),
                map("it", "template", "Template"),
                map("dj", "today", "Today"),
                map("dh", "today -1", "Previous Day"),
                map("dl", "today +1", "Next Day"),
                map("dd", "dailies", "Dailies"),
            }
        end,
    },

    {
        "magnusriga/markdown-tools.nvim",
        dependencies = "folke/snacks.nvim",
        ft = "markdown",
        opts = {
            picker = "snacks",

            -- Obsidian should handle this
            insert_frontmatter = false,

            frontmatter_date = function()
                return date_format
            end,

            commands = {
                -- All these are hanlded by Obsidian
                create_from_template = false,
                insert_checkbox = false,
                toggle_checkbox = true,
            },

            -- Keymappings for shortcuts. Set to `false` or `""` to disable.
            keymaps = {
                insert_header = "<localleader>iH", -- Header
                insert_code_block = "<localleader>ic", -- Code block
                insert_bold = "<localleader>ib", -- Bold
                insert_highlight = "<localleader>ih", -- Highlight
                insert_italic = "<localleader>ii", -- Italic
                insert_link = "<localleader>il", -- Link
                insert_table = "<localleader>iT", -- Table
                insert_checkbox = "<localleader>ik", -- Checkbox
                toggle_checkbox = "<C-t>", -- Toggle Checkbox
                preview = "<localleader>p", -- Preview
            },

            -- This handles Obisidian
            enable_local_options = false,
        },
    },

    {
        "OXY2DEV/markview.nvim",
        lazy = false,
        enabled = false,
        dependencies = {
            "saghen/blink.cmp",
        },
        opts = {
            preview = {
                enable = false,
                icon_provider = "mini",
            },
        },
        keys = {
            { "<localleader>p", "<cmd>Markview toggle<cr>", desc = "Preview" },
        },
    },
}
