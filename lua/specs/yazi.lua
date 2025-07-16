-- NOTE: Image Preview does not work: https://yazi-rs.github.io/docs/image-preview/#neovim

---@type LazySpec
return {
    "mikavilpas/yazi.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "VeryLazy",
    keys = {
        {
            "<leader>f",
            function()
                require("yazi").yazi()
            end,
            desc = "[E]xplorer",
        },
        {
            "<leader>F",
            function()
                require("yazi").yazi(nil, vim.fn.getcwd())
            end,
            desc = "[E]xplorer (Root)",
        },
    },

    ---@type YaziConfig
    opts = {
        yazi_floating_window_winblend = 10,
        floating_window_scaling_factor = 0.9,
        yazi_floating_window_border = "solid",
    },
}
