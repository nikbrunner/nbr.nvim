local ui = require("nbr.lib.ui")

-- NOTE: Image Preview does not work: https://yazi-rs.github.io/docs/image-preview/#neovim

---@type LazySpec
return {
    "mikavilpas/yazi.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "VeryLazy",
    enabled = false,
    keys = {
        {
            "<leader>we",
            function()
                require("yazi").yazi()
            end,
            desc = "[E]xplorer",
        },
        {
            "<leader>wE",
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
        ---@diagnostic disable-next-line: missing-fields
        hooks = {
            yazi_opened = function()
                ui.create_backdrop()
            end,
            yazi_closed_successfully = function()
                ui.close_backdrop()
            end,
        },
    },
}
