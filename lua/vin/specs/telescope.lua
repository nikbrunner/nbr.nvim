local M = {}

---@type LazySpec
M.spec = {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    event = "VeryLazy",
    ---@diagnostic disable-next-line: assign-type-mismatch
    version = false, -- telescope did only one release, so use HEAD for now
    dependencies = {
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            build = "make",
            enabled = vim.fn.executable("make") == 1,
            config = function()
                require("telescope").load_extension("fzf")
            end,
        },
    },
    keys = {
        -- Most fuzzy searching commands are run via fzflua
        { "<leader>so", "<cmd>Telescope vim_options<cr>", desc = "Options" },
    },
    opts = function()
        local actions = require("telescope.actions")

        local quick_flex_window = {
            show_line = false,
            layout_strategy = "flex",
            layout_config = {
                width = 0.65,
                height = 0.65,
                preview_cutoff = 1,
                mirror = false,
                flip_columns = 150,
            },
        }

        ---@diagnostic disable-next-line: unused-local
        local quick_cursor_window = {
            show_line = false,
            theme = "cursor",
            initial_mode = "insert",
        }

        local open_with_trouble = function(...)
            return require("trouble.providers.telescope").open_with_trouble(...)
        end
        local open_selected_with_trouble = function(...)
            return require("trouble.providers.telescope").open_selected_with_trouble(...)
        end

        return {
            defaults = {
                prompt_prefix = " ",
                selection_caret = " ",
                initial_mode = "insert",
                selection_strategy = "reset",
                sorting_strategy = "descending",
                layout_strategy = "flex",
                path_display = { "truncate" },
                layout_config = {
                    horizontal = {
                        height = 0.9,
                        preview_cutoff = 0,
                        prompt_position = "bottom",
                        width = 0.8,
                        preview_width = 0.5,
                    },
                    vertical = {
                        height = 0.95,
                        show_line = false,
                        preview_height = 0.5,
                        preview_cutoff = 0,
                        prompt_position = "bottom",
                        width = 0.8,
                    },
                    bottom_pane = {
                        show_line = false,
                        height = 25,
                        preview_cutoff = 0,
                        prompt_position = "top",
                    },
                    center = {
                        show_line = false,
                        height = 0.4,
                        preview_cutoff = 0,
                        prompt_position = "top",
                        width = 0.5,
                    },
                    cursor = {
                        show_line = false,
                        height = 0.9,
                        preview_cutoff = 40,
                        width = 0.8,
                    },
                    width = 0.65,
                    height = 0.65,
                    preview_cutoff = 10,
                },
                mappings = {
                    i = {
                        ["<ESC>"] = actions.close,

                        ["<C-l>"] = actions.cycle_history_next,
                        ["<C-h>"] = actions.cycle_history_prev,

                        ["<Down>"] = actions.move_selection_next,
                        ["<Up>"] = actions.move_selection_previous,

                        ["<CR>"] = actions.select_default,
                        ["<C-x>"] = actions.select_horizontal,
                        ["<C-v>"] = actions.select_vertical,
                        ["<C-t>"] = actions.select_tab,

                        ["<C-u>"] = actions.preview_scrolling_up,
                        ["<C-d>"] = actions.preview_scrolling_down,

                        ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
                        ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
                        ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
                        ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
                        ["<C-_>"] = actions.which_key, -- keys from pressing <C-/>

                        ["<c-t>"] = open_with_trouble,
                        ["<a-t>"] = open_selected_with_trouble,
                    },
                    n = {
                        ["q"] = actions.close,

                        ["<C-h>"] = actions.cycle_history_next,
                        ["<C-l>"] = actions.cycle_history_prev,

                        ["<Down>"] = actions.move_selection_next,
                        ["<Up>"] = actions.move_selection_previous,

                        ["gg"] = actions.move_to_top,
                        ["G"] = actions.move_to_bottom,

                        ["<CR>"] = actions.select_default,
                        ["x"] = actions.select_horizontal,
                        ["v"] = actions.select_vertical,
                        ["t"] = actions.select_tab,

                        ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
                        ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
                        ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
                        ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,

                        ["<C-u>"] = actions.preview_scrolling_up,
                        ["<C-d>"] = actions.preview_scrolling_down,

                        ["<PageUp>"] = actions.results_scrolling_up,
                        ["<PageDown>"] = actions.results_scrolling_down,

                        ["?"] = actions.which_key,
                    },
                },
            },
            pickers = {
                find_files = {
                    hidden = true,
                    file_ignore_patterns = { "^.git/", "^node_modules/" },
                    show_line = false,
                    theme = "ivy",
                    initial_mode = "insert",
                },
                lsp_definitions = quick_flex_window,
                lsp_references = quick_flex_window,
                lsp_implementations = quick_flex_window,
                lsp_type_definitions = quick_flex_window,
                lsp_document_symbols = quick_flex_window,
                lsp_workspace_symbols = quick_flex_window,
                diagnostics = quick_flex_window,
                git_files = quick_flex_window,
                git_status = {
                    theme = "ivy",
                    initial_mode = "insert",
                },
                list_tabs = {
                    theme = "dropdown",
                    initial_mode = "insert",
                },
                buffers = vim.tbl_extend("keep", quick_flex_window, {
                    initial_mode = "insert",
                }),
                current_buffer_fuzzy_find = {
                    theme = "ivy",
                },
                spell_suggest = {
                    theme = "cursor",
                },
                colorscheme = {
                    theme = "dropdown",
                    enable_preview = true,
                },
                oldfiles = quick_flex_window,
                commands = {
                    theme = "ivy",
                },
            },
        }
    end,
}

return M.spec