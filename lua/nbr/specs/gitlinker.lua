---@type LazyPluginSpec
return {
    "linrongbin16/gitlinker.nvim",
    cmd = "GitLink",
    event = "BufEnter",
    keys = {
        {
            mode = { "n", "v" },
            "<leader>dyg",
            "<CMD>GitLink<CR>",
            desc = "[G]itHub Link",
        },
    },
    opts = {},
}
