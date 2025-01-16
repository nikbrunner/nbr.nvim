---@type LazyPluginSpec
return {
    "linrongbin16/gitlinker.nvim",
    cmd = "GitLink",
    event = "BufEnter",
    keys = {
        {
            mode = { "n", "v" },
            "<leader>dyr",
            "<CMD>GitLink<CR>",
            desc = "[R]emote Link",
        },
    },
    opts = {},
}
