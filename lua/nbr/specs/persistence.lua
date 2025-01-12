---@type LazyPluginSpec
return {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {},
    keys = function()
        local ps = require("persistence")

        return {
            { "<leader>wSs", ps.select, desc = "Select session" },
            { "<leader>wSl", ps.load, desc = "Load session" },
            {
                "<leader>wSr",
                function()
                    ps.load({ last = true })
                end,
                desc = "Restore session",
            },
        }
    end,
}
