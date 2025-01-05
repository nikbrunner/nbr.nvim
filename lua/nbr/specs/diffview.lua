return {
    "sindrets/diffview.nvim",
    event = "VimEnter",
    opts = {
        enhanced_diff_hl = true, -- See |diffview-config-enhanced_diff_hl|
    },
    keys = {
        { "<leader>wvd", "<CMD>DiffviewOpen<CR>", desc = "[D]iff" },
        { "<leader>dL", "<CMD>DiffviewFileHistory %<CR>", desc = "[L]og" },
    },
}
