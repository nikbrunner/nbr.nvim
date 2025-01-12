---@type LazyPluginSpec
return {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    opts = {
        options = {
            mode = "tabs", -- set to "tabs" to only show tabpages instead
            diagnostics = "nvim_lsp",
            always_show_bufferline = false,
            separator_style = "slant",
            show_buffer_close_icons = false,
            show_close_icon = false,
            offsets = {
                {
                    filetype = "neo-tree",
                    text = "Neo-tree",
                    highlight = "Directory",
                    text_align = "left",
                },
            },
        },
    },
}
