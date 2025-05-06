---@type LazyPluginSpec
return {
    "magnusriga/markdown-tools.nvim",
    dependencies = "folke/snacks.nvim",
    ft = "markdown",
    opts = {
        picker = "snacks",

        -- Keymappings for shortcuts. Set to `false` or `""` to disable.
        keymaps = {
            create_from_template = "<leader>mnt", -- New Template
            insert_header = "<leader>mH", -- Header
            insert_code_block = "<leader>mc", -- Code block
            insert_bold = "<leader>mb", -- Bold
            insert_highlight = "<leader>mh", -- Highlight
            insert_italic = "<leader>mi", -- Italic
            insert_link = "<leader>ml", -- Link
            insert_table = "<leader>mt", -- Table
            insert_checkbox = "<leader>mk", -- Checkbox
            toggle_checkbox = "<leader>mx", -- Toggle Checkbox
            preview = "<leader>mp", -- Preview
        },

        conceallevel = 0,
        concealcursor = "",
    },
}
