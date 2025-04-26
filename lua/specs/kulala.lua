---@type LazyPluginSpec
return {
    "mistweaverco/kulala.nvim",
    pin = true,
    ft = "http",
    ---@doc: [Setup Options | Kulala.nvim](https://kulala.mwco.app/docs/getting-started/setup-options/)
    opts = {
        winbar = true,
    },
    keys = function()
        local kulala = require("kulala")

        return {
            { "[h", kulala.jump_prev, desc = "Previous request" },
            { "]h", kulala.jump_next, desc = "Next request" },
            { "<leader>rr", kulala.run, desc = "Run request" },
            { "<leader>r.", kulala.replay, desc = "Re-Run request" },
            { "<leader>re", kulala.set_selected_env, desc = "Select env" },
            { "<leader>rs", kulala.search, desc = "Search" },
            { "<leader>rc", kulala.copy, desc = "Copy request" },
        }
    end,
}
