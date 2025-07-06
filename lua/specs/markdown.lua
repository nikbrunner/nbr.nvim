---@diagnostic disable: missing-fields

local Config = require("config")
local date_format = "%Y.%m.%d - %A"

---@type LazyPluginSpec[]
return {
    {
        "obsidian-nvim/obsidian.nvim",
        version = "*", -- recommended, use latest release instead of latest commit
        event = "VeryLazy",
        dependencies = {
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
                            folder = string.format("02 - Areas/Log/%d/%02d-%s", os.date("%Y"), os.date("%m"), os.date("%B")),
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
                ["<C-t>"] = {
                    action = function()
                        return require("obsidian").util.toggle_checkbox()
                    end,
                    opts = { buffer = true },
                },
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
                enable = false,
            },
        },
        config = function(_, opts)
            require("obsidian").setup(opts)

            -- Define vault paths once
            local cwd = vim.fn.getcwd()
            local personal_vault = vim.fn.expand(Config.pathes.notes.personal)
            local work_vault = vim.fn.expand(Config.pathes.notes.work.dcd)

            -- Function to check and open today's note
            local function open_daily_note_if_in_vault()
                local current_cwd = vim.fn.getcwd()

                -- Check if we're in either vault (exact match or subdirectory)
                if
                    current_cwd == personal_vault
                    or current_cwd:match("^" .. vim.pesc(personal_vault) .. "/")
                    or current_cwd == work_vault
                    or current_cwd:match("^" .. vim.pesc(work_vault) .. "/")
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

            -- Fire the ready event if we're in a vault
            if
                cwd == personal_vault
                or cwd:match("^" .. vim.pesc(personal_vault) .. "/")
                or cwd == work_vault
                or cwd:match("^" .. vim.pesc(work_vault) .. "/")
            then
                vim.api.nvim_exec_autocmds("User", { pattern = "ObsidianReady" })
            end

            -- Always create keymaps that will switch workspace based on context
            local map = vim.keymap.set

            -- Helper to get the appropriate workspace
            local function get_workspace()
                local current_cwd = vim.fn.getcwd()
                return current_cwd:match("dealercenter%-digital") and "dcd" or "personal"
            end

            -- Helper to check if we're in a vault
            local function in_vault()
                local current_cwd = vim.fn.getcwd()
                return current_cwd == personal_vault
                    or current_cwd:match("^" .. vim.pesc(personal_vault) .. "/")
                    or current_cwd == work_vault
                    or current_cwd:match("^" .. vim.pesc(work_vault) .. "/")
            end

            -- Helper to ensure we're in the right workspace before running command
            local function with_workspace(cmd)
                return function()
                    local workspace = get_workspace()
                    local client = require("obsidian").get_client()
                    if client and client.current_workspace.name ~= workspace then
                        client:switch_workspace(workspace)
                    end

                    -- If we're not in a vault, open in a vertical split
                    if not in_vault() then
                        -- Save current window
                        local current_win = vim.api.nvim_get_current_win()
                        -- Create vertical split
                        vim.cmd("vsplit")
                        -- Run the command
                        vim.cmd(cmd)
                        -- Set up autocmd to return focus when leaving the split
                        vim.api.nvim_create_autocmd("WinLeave", {
                            buffer = vim.api.nvim_get_current_buf(),
                            once = true,
                            callback = function()
                                -- Return to original window if it still exists
                                if vim.api.nvim_win_is_valid(current_win) then
                                    vim.api.nvim_set_current_win(current_win)
                                end
                            end,
                        })
                    else
                        vim.cmd(cmd)
                    end
                end
            end

            map("n", "<leader>nf", with_workspace("Obsidian quick_switch"), { desc = "[F]ind Note (Obsidian)" })
            map("n", "<leader>ns", with_workspace("Obsidian search"), { desc = "[S]earch Notes (Obsidian)" })
            map("n", "<leader>nt", with_workspace("Obsidian template"), { desc = "Insert [T]emplate (Obsidian)" })
            map("n", "<leader>nj", with_workspace("Obsidian today"), { desc = "Today's Note" })
            map("n", "<leader>nh", with_workspace("Obsidian today -1"), { desc = "Yesterday's Note" })
            map("n", "<leader>nl", with_workspace("Obsidian today +1"), { desc = "Tomorrow's Note" })
            map("n", "<leader>nd", with_workspace("Obsidian dailies"), { desc = "[D]aily Notes List" })
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
                toggle_checkbox = false,
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
                insert_checkbox = "<leader>nit", -- Checkbox (checKbox)
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
