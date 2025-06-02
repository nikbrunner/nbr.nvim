---@diagnostic disable: missing-fields

local Config = require("config")
local date_format = "%Y.%m.%d - %A"

---@type LazyPluginSpec[]
return {
    {
        "obsidian-nvim/obsidian.nvim",
        version = "*", -- recommended, use latest release instead of latest commit
        ft = "markdown",
        event = function()
            local events = {
                "BufReadPre " .. Config.pathes.notes.personal .. "/*.md",
                "BufReadPre " .. Config.pathes.notes.work.dcd .. "/*.md",
            }

            -- Check if we're starting in a vault
            local cwd = vim.fn.getcwd()
            local personal_vault = vim.fn.expand(Config.pathes.notes.personal)
            local work_vault = vim.fn.expand(Config.pathes.notes.work.dcd)

            if
                cwd == personal_vault
                or cwd:match("^" .. vim.pesc(personal_vault) .. "/")
                or cwd == work_vault
                or cwd:match("^" .. vim.pesc(work_vault) .. "/")
            then
                -- Add VimEnter to load immediately
                table.insert(events, "VimEnter")
            end

            return events
        end,
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
                            substitutions = {
                                ["date:YYYY.MM.DD - dddd"] = function()
                                    return os.date("%Y.%m.%d - %A")
                                end,
                            },
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
                            substitutions = {
                                ["date:YYYY.MM.DD - dddd"] = function()
                                    return os.date("%Y.%m.%d - %A")
                                end,
                            },
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
        config = function(_, opts)
            require("obsidian").setup(opts)

            -- Function to check and open today's note
            local function open_daily_note_if_in_vault()
                local cwd = vim.fn.getcwd()
                local personal_vault = vim.fn.expand(Config.pathes.notes.personal)
                local work_vault = vim.fn.expand(Config.pathes.notes.work.dcd)

                -- Check if we're in either vault (exact match or subdirectory)
                if
                    cwd == personal_vault
                    or cwd:match("^" .. vim.pesc(personal_vault) .. "/")
                    or cwd == work_vault
                    or cwd:match("^" .. vim.pesc(work_vault) .. "/")
                then
                    vim.cmd("Obsidian today")
                end
            end

            -- Create autocmd group
            local group = vim.api.nvim_create_augroup("ObsidianAutoDaily", { clear = true })

            -- Auto-open today's note when entering vault
            vim.api.nvim_create_autocmd("DirChanged", {
                group = group,
                callback = open_daily_note_if_in_vault,
            })

            -- Also check on first buffer enter (for when we start in vault)
            vim.api.nvim_create_autocmd("User", {
                group = group,
                pattern = "ObsidianReady",
                once = true,
                callback = function()
                    vim.defer_fn(open_daily_note_if_in_vault, 100)
                end,
            })

            -- Fire the ready event
            vim.api.nvim_exec_autocmds("User", { pattern = "ObsidianReady" })

            -- Create keymaps only when in vault
            local cwd = vim.fn.getcwd()
            local personal_vault = vim.fn.expand(Config.pathes.notes.personal)
            local work_vault = vim.fn.expand(Config.pathes.notes.work.dcd)

            if
                cwd == personal_vault
                or cwd:match("^" .. vim.pesc(personal_vault) .. "/")
                or cwd == work_vault
                or cwd:match("^" .. vim.pesc(work_vault) .. "/")
            then
                -- Set up keymaps only when in a vault
                local map = vim.keymap.set
                map("n", "<leader>nf", "<cmd>Obsidian quick_switch<cr>", { desc = "[F]ind Note (Obsidian)" })
                map("n", "<leader>ns", "<cmd>Obsidian search<cr>", { desc = "[S]earch Notes (Obsidian)" })
                map("n", "<leader>nt", "<cmd>Obsidian template<cr>", { desc = "Insert [T]emplate (Obsidian)" })
                map("n", "<leader>nj", "<cmd>Obsidian today<cr>", { desc = "Today's Note" })
                map("n", "<leader>nh", "<cmd>Obsidian today -1<cr>", { desc = "Yesterday's Note" })
                map("n", "<leader>nl", "<cmd>Obsidian today +1<cr>", { desc = "Tomorrow's Note" })
                map("n", "<leader>nd", "<cmd>Obsidian dailies<cr>", { desc = "[D]aily Notes List" })
            end
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
                -- Use <leader>ni prefix for markdown insert operations
                insert_header = "<leader>niH", -- Header
                insert_code_block = "<leader>nic", -- Code block
                insert_bold = "<leader>nib", -- Bold
                insert_highlight = "<leader>nih", -- Highlight
                insert_italic = "<leader>nii", -- Italic
                insert_link = "<leader>nil", -- Link
                insert_table = "<leader>niT", -- Table
                insert_checkbox = "<leader>nik", -- Checkbox (checKbox)
                toggle_checkbox = "<C-t>", -- Toggle Checkbox (keep this as is)
                preview = "<leader>np", -- Preview
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
