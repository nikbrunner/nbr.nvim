---@type LazyPluginSpec
return {
    "akinsho/bufferline.nvim",
    -- STARTUP OPTIMIZATION: Load only when we have multiple tabs
    -- Since mode = "tabs", it only shows tabpages, so we load it on TabNew
    event = { "TabNew" },
    opts = {
        options = {
            mode = "tabs", -- set to "tabs" to only show tabpages instead
            diagnostics = "nvim_lsp",
            always_show_bufferline = false,
            separator_style = "thick",
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
