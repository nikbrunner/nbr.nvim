return {
    "fredrikaverpil/pr.nvim",
    version = "*",
    cmd = { "PRView" },
    ---@type PR.Config
    opts = {},
    keys = {
        {
            "<leader>sG",
            function()
                require("pr").view()
            end,
            desc = "View PR in browser",
        },
    },
}
