---@type LazyPluginSpec
return {
    "uga-rosa/ccc.nvim",
    event = "VeryLazy",
    keys = { { "<leader>ac", "<cmd>CccPick<CR>", desc = "[C]olor Picker" } },
    opts = function()
        -- Documentation: https://github.com/uga-rosa/ccc.nvim
        -- Defaults: https://github.com/uga-rosa/ccc.nvim/blob/main/lua/ccc/config/default.lua
        local ccc = require("ccc")

        local input = ccc.input
        local output = ccc.output
        local picker = ccc.picker

        return {
            ---@type string hex
            default_color = "#000000",
            ---@type string
            bar_char = "■",
            ---@type string
            point_char = "◇",
            ---@type string hex
            point_color = "",
            ---@type integer
            bar_len = 30,
            ---@type table
            win_opts = {
                relative = "cursor",
                row = 1,
                col = 1,
                style = "minimal",
                border = "rounded",
            },
            ---@type boolean
            auto_close = true,
            ---@type boolean
            preserve = false,
            ---@type boolean
            save_on_quit = true,
            alpha_show = "auto",
            inputs = {
                input.hsl,
            },
            outputs = {
                output.hex,
                output.hex_short,
                output.css_rgb,
                output.css_hsl,
            },
            pickers = {
                picker.hex,
                picker.css_rgb,
                picker.css_hsl,
                picker.css_hwb,
                picker.css_lab,
                picker.css_lch,
                picker.css_oklab,
                picker.css_oklch,
            },
            ---@type table<string, string[] | string | nil>
            exclude_pattern = {
                hex = {
                    "[%w_]{{pattern}}",
                    "{{pattern}}[g-zG-Z_]",
                },
                css_rgb = nil,
                css_hsl = nil,
                css_hwb = nil,
                css_name = {
                    "[%w_]{{pattern}}",
                    "{{pattern}}[%w_]",
                },
            },
            highlight_mode = "bg",
            ---@type function
            output_line = ccc.output_line,
            ---@type table
            highlighter = {
                ---@type boolean
                auto_enable = true,
                ---@type integer
                max_byte = 100 * 1024, -- 100 KB
                ---@type string[]
                filetypes = {},
                ---@type string[]
                excludes = {},
                ---@type boolean
                lsp = true,
            },
            convert = {
                { picker.hex, output.css_rgb },
                { picker.css_rgb, output.css_hsl },
                { picker.css_hsl, output.hex },
            },
            recognize = {
                input = false,
                output = false,
                pattern = {
                    [picker.hex] = { input.rgb, output.hex },
                    [picker.css_hsl] = { input.hsl, output.css_hsl },
                    [picker.css_hwb] = { input.hwb, output.css_hwb },
                    [picker.css_lab] = { input.lab, output.css_lab },
                    [picker.css_lch] = { input.lch, output.css_lch },
                },
            },
        }
    end,
}
