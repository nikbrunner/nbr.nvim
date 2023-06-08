return {
    "nvim-neo-tree/neo-tree.nvim",
    cmd = "Neotree",
    lazy = false,
    init = function()
        vim.g.neo_tree_remove_legacy_commands = 1
    end,
    opts = {
        -- Fix for NerdFonts v3
        -- https://github.com/nvim-neo-tree/neo-tree.nvim#configuration-for-nerd-fonts-v3-users
        default_component_configs = {
            icon = {
                folder_empty = "󰜌",
                folder_empty_open = "󰜌",
            },
            git_status = {
                symbols = {
                    renamed = "󰁕",
                    unstaged = "󰄱",
                },
            },
        },
        document_symbols = {
            kinds = {
                File = { icon = "󰈙", hl = "Tag" },
                Namespace = { icon = "󰌗", hl = "Include" },
                Package = { icon = "󰏖", hl = "Label" },
                Class = { icon = "󰌗", hl = "Include" },
                Property = { icon = "󰆧", hl = "@property" },
                Enum = { icon = "󰒻", hl = "@number" },
                Function = { icon = "󰊕", hl = "Function" },
                String = { icon = "󰀬", hl = "String" },
                Number = { icon = "󰎠", hl = "Number" },
                Array = { icon = "󰅪", hl = "Type" },
                Object = { icon = "󰅩", hl = "Type" },
                Key = { icon = "󰌋", hl = "" },
                Struct = { icon = "󰌗", hl = "Type" },
                Operator = { icon = "󰆕", hl = "Operator" },
                TypeParameter = { icon = "󰊄", hl = "Type" },
                StaticMethod = { icon = "󰠄 ", hl = "Function" },
            },
        },
        -- @see [nvim/neo-tree.lua at loctvl842/nvim · GitHub](https://github.com/loctvl842/nvim/blob/7894bfa85e4e3c06bb81e5169d1c9c41a892aa34/lua/tvl/config/neo-tree.lua)
        enable_git_status = true,
        enable_diagnostics = true,
        source_selector = {
            winbar = false,
            statusline = false, -- toggle to show selector on statusline
            content_layout = "center",
            tabs_layout = "equal",
            sources = {
                {
                    source = "filesystem",
                    display_name = Vin.icons.ui.Folder .. " Files",
                },
                {
                    source = "git_status",
                    display_name = Vin.icons.git.Diff .. " Git",
                },
                {
                    source = "buffers",
                    display_name = Vin.icons.ui.Stack .. " Buffers",
                },
            },
        },
        filesystem = {
            bind_to_cwd = true,
            follow_current_file = true,
            -- "open_default" would be nice but sometimes on inital load and i open telescope or fzf it sometimes get stuck
            hijack_netrw_behavior = "open_default",
            components = {
                harpoon_index = function(config, node)
                    local Marked = require("harpoon.mark")
                    local path = node:get_id()
                    local succuss, index = pcall(Marked.get_index_of, path)
                    if succuss and index and index > 0 then
                        return {
                            text = string.format(" ⥤ %d", index), -- <-- Add your favorite harpoon like arrow here
                            highlight = config.highlight or "NeoTreeDirectoryIcon",
                        }
                    else
                        return {}
                    end
                end,
            },
            renderers = {
                file = {
                    { "icon" },
                    { "name", use_git_status_colors = true },
                    { "harpoon_index" }, --> This is what actually adds the component in where you want it
                    { "diagnostics" },
                    { "git_status", highlight = "NeoTreeDimText" },
                },
            },
        },
        nesting_rules = {
            ["ts"] = { "spec.ts" },
        },
        event_handlers = {
            -- {
            --     event = "file_opened",
            --     handler = function(file_path)
            --         require("neo-tree").close_all()
            --     end,
            -- },
        },
        window = { -- see https://github.com/MunifTanjim/nui.nvim/tree/main/lua/nui/popup for
            -- possible options. These can also be functions that return these options.
            position = "left", -- left, right, top, bottom, float, current
            width = Vin.config.sidebar_width, -- applies to left and right positions
            mappings = {
                ["<space>"] = false, -- disable for leader
                ["<2-LeftMouse>"] = "open",
                ["<cr>"] = "open",
                ["<esc>"] = "revert_preview",
                ["P"] = { "toggle_preview", config = { use_float = true } },
                ["s"] = "open_split",
                ["S"] = "split_with_window_picker",
                ["v"] = "open_vsplit",
                ["V"] = "vsplit_with_window_picker",
                ["t"] = "open_tabnew",
                ["w"] = "open_with_window_picker",
                ["C"] = "close_node",
                ["M"] = "close_all_nodes",
                ["O"] = "expand_all_nodes",
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
    },
}
