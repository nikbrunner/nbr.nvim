local M = {}

---@type LazyPluginSpec
M.spec = {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    event = "VeryLazy",
    enabled = false,
    dependencies = {
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
    },
    ---@diagnostic disable-next-line: assign-type-mismatch
    keys = function()
        local function close_side_panels()
            vim.cmd("Neotree left close")
            vim.cmd("Neotree right close")
        end

        return {
            {
                "<M-[>",
                function()
                    vim.cmd("Neotree left toggle reveal")
                end,
                desc = "Explorer (Left)",
            },
            {
                "<M-]>",
                function()
                    vim.cmd("Neotree right git_status toggle reveal")
                end,
                desc = "Git Status (Right)",
            },
            {
                "<leader>ee",
                function()
                    vim.cmd("Neotree float toggle reveal")
                end,
                desc = "Explorer",
            },
            {
                "<leader>eg",
                function()
                    vim.cmd("Neotree float git_status toggle reveal")
                end,
                desc = "Git Status",
            },
            {
                "<leader>er",
                function()
                    vim.cmd("Neotree float buffers toggle reveal")
                end,
                desc = "Recents",
            },
            {
                "<leader>eh",
                function()
                    vim.cmd("Neotree float toggle reveal git_status origin/HEAD")
                end,
                desc = "Head Status",
            },
            {
                "<leader>eH",
                function()
                    -- close_side_panels()
                    local all_branches = vim.fn.system("git branch -a")
                    local branches = vim.split(all_branches, "\n")

                    vim.ui.select(branches, {
                        prompt = "Select a branch: ",
                    }, function(branch)
                        if branch == nil then
                            return
                        else
                            vim.ui.select({
                                "float",
                                "top",
                                "right",
                                "bottom",
                                "left",
                            }, {
                                prompt = "Select a Neotree position: ",
                            }, function(position)
                                if position == nil then
                                    return
                                else
                                    vim.cmd("Neotree " .. position .. " toggle reveal git_status " .. branch)
                                end
                            end)
                        end
                    end)
                end,
                desc = "Head Status (Choose)",
            },
        }
    end,
    --- https://github.com/nvim-neo-tree/neo-tree.nvim/blob/v3.x/lua/neo-tree/defaults.lua
    opts = function()
        local icons = require("icons")
        local events = require("neo-tree.events")
        local Snacks = require("snacks")

        local function on_move(data)
            Snacks.rename.on_rename_file(data.source, data.destination)
        end

        return {
            default_component_configs = {
                indent = {
                    with_markers = false,
                    expander_collapsed = "",
                    expander_expanded = "",
                },
                diagnostics = {
                    symbols = {
                        hint = icons.diagnostics.Hint,
                        info = icons.diagnostics.Info,
                        warn = icons.diagnostics.Warn,
                        error = icons.diagnostics.Error,
                    },
                },
                git_status = {
                    symbols = {
                        added = icons.git.added,
                        deleted = icons.git.removed,
                        modified = icons.git.modified,
                        renamed = icons.git.renamed,
                        untracked = icons.git.untracked,
                        ignored = icons.git.ignored,
                        unstaged = icons.git.unstaged,
                        staged = icons.git.staged,
                        conflict = icons.git.conflict,
                    },
                },
                icon = {
                    folder_closed = " ",
                    folder_open = " ",
                    folder_empty = " ",
                    folder_empty_open = " ",
                    default = "",
                },
                file_size = {
                    enabled = false,
                },
            },
            add_blank_line_at_top = true,
            hide_root_node = true,
            sources = {
                "filesystem",
                "buffers",
                "git_status",
                "document_symbols",
            },
            filesystem = {
                hijack_netrw_behavior = "disabled",
                use_libuv_file_watcher = true, -- This will use the OS level file watchers to detect changes
                follow_current_file = {
                    enabled = true, -- This will find and focus the file in the active buffer every time the current file is changed while the tree is open.
                },
                -- the current file is changed while the tree is open.
                filtered_items = {
                    visible = false, -- when true, they will just be displayed differently than normal items
                    force_visible_in_empty_folder = false, -- when true, hidden files will be shown if the root folder is otherwise empty
                    show_hidden_count = true, -- when true, the number of hidden items in each folder will be shown as the last entry
                    hide_dotfiles = false,
                    hide_gitignored = true,
                    hide_hidden = false, -- only works on Windows for hidden files/directories
                    always_show = { -- remains visible even if other settings would normally hide it
                        ".gitignore",
                    },
                    never_show = { -- remains hidden even if visible is toggled to true, this overrides always_show
                        ".DS_Store",
                        "thumbs.db",
                    },
                },
            },
            source_selector = {
                winbar = false,
                show_scrolled_off_parent_node = true,
                statusline = false, -- toggle to show selector on statusline
                content_layout = "center",
                tabs_layout = "equal",
                sources = { -- table
                    {
                        source = "filesystem", -- string
                        display_name = " 󰉓 Files ", -- string | nil
                    },
                    {
                        source = "buffers", -- string
                        display_name = " 󰈚 Buffers ", -- string | nil
                    },
                    {
                        source = "git_status", -- string
                        display_name = " 󰊢 Git ", -- string | nil
                    },
                },
            },

            event_handlers = {
                { event = events.FILE_MOVED, handler = on_move },
                { event = events.FILE_RENAMED, handler = on_move },
                {
                    event = "neo_tree_window_after_open",
                    handler = function()
                        vim.cmd("wincmd =")
                    end,
                },

                {
                    event = "neo_tree_window_after_close",
                    handler = function()
                        vim.cmd("wincmd =")
                    end,
                },
            },

            window = {
                position = "left",
                width = 0.2,
                -- https://github.com/MunifTanjim/nui.nvim/tree/main/lua/nui/popup
                popup = {
                    position = "50%", -- 50% means center it
                    size = {
                        height = 0.65,
                        width = 65,
                    },
                    border = {
                        padding = { 1, 4 },
                        style = "solid",
                    },
                },
                mappings = {
                    ["<space>"] = false,
                    ["<2-LeftMouse>"] = "open",
                    ["<cr>"] = "open",
                    ["L"] = "open",
                    ["<esc>"] = "revert_preview",
                    ["P"] = { "toggle_preview", config = { use_float = true } },
                    ["<C-s>"] = "open_split",
                    ["<C-v>"] = "open_vsplit",
                    ["<C-t>"] = "open_tabnew",
                    ["<C-d>"] = { "scroll_preview", config = { direction = 10 } },
                    ["<C-u>"] = { "scroll_preview", config = { direction = -10 } },
                    ["/"] = "noop",
                    ["l"] = "focus_preview",
                    ["O"] = function(state)
                        local node = state.tree:get_node()
                        local path = node:get_id()
                        vim.ui.open(path)
                    end,
                    ["M"] = "close_all_nodes",
                    ["R"] = "refresh",
                    ["a"] = { "add", config = { show_path = "relative" } }, -- "none", "relative", "absolute"
                    ["A"] = "add_directory", -- also accepts the config.show_path option.
                    ["d"] = "delete",
                    ["r"] = "rename",
                    ["y"] = "copy_to_clipboard",
                    ["x"] = "cut_to_clipboard",
                    ["p"] = "paste_from_clipboard",
                    ["c"] = "copy", -- takes text input for destination, also accepts the config.show_path option
                    ["m"] = "move", -- takes text input for destination, also accepts the config.show_path option
                    ["e"] = "toggle_auto_expand_width",
                    ["q"] = "close_window",
                    ["?"] = "show_help",
                    ["<"] = "prev_source",
                    [">"] = "next_source",
                },
            },
        }
    end,
    config = function(_, opts)
        require("neo-tree").setup(opts)
    end,
}

return M.spec
