return {
    "sindrets/diffview.nvim",
    event = "VimEnter",
    opts = {
        enhanced_diff_hl = true, -- See |diffview-config-enhanced_diff_hl|
    },
    keys = {
        { "<leader>wvd", "<CMD>DiffviewOpen<CR>", desc = "[D]iff" },
        { "<leader>wH", "<CMD>DiffviewFileHistory<CR>", desc = "[H]istory (Diffview)" },
        { "<leader>dH", "<CMD>DiffviewFileHistory %<CR>", desc = "[H]istory (Diffview)" },
    },
}
