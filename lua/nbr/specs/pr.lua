return {
    "fredrikaverpil/pr.nvim",
    version = "*",
    cmd = { "PRView" },
    ---@type PR.Config
    opts = {},
    keys = {
        {
            "sP",
            function()
                require("pr").view()
            end,
            desc = "View PR in browser",
        },
    },
}
