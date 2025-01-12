local M = {}

---@type LazyPluginSpec
M.spec = {
    "numToStr/Navigator.nvim",
    keys = {
        { "<C-h>", "<CMD>NavigatorLeft<CR>" },
        { "<C-l>", "<CMD>NavigatorRight<CR>" },
        { "<C-k>", "<CMD>NavigatorUp<CR>" },
        { "<C-j>", "<CMD>NavigatorDown<CR>" },
    },
    config = function(_, opts)
        require("Navigator").setup(opts)
    end,
}

return M.spec
