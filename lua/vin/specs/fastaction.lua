---@type LazyPluginSpec
return {
    "Chaitanyabsprip/fastaction.nvim",
    event = "BufRead",
    ---@module "fastaction"
    ---@type FastActionConfig
    opts = {
        dismiss_keys = { "j", "k", "<c-c>", "q" },
        keys = "qwertyuiopasdfghlzxcvbnm",
        popup = {
            relative = "cursor",
            border = "solid",
            hide_cursor = true,
            highlight = {
                divider = "FloatBorder",
                key = "MoreMsg",
                title = "Title",
                window = "NormalFloat",
            },
            title = "Select one of:",
        },
        priority = {
            javascript = {
                { pattern = "add braces", key = "a", order = 1 },
            },
            javascriptreact = {
                { pattern = "add braces", key = "a", order = 1 },
            },
            typescript = {
                { pattern = "add braces", key = "a", order = 1 },
            },
            typescriptreact = {
                { pattern = "add braces", key = "a", order = 1 },
            },
        },
    },
    keys = {
        {
            "g.",
            function()
                require("fastaction").code_action()
            end,
            desc = "Code Action",
        },
        {
            "g.",
            mode = "v",
            function()
                require("fastaction").range_code_action()
            end,
            desc = "Code Action",
        },
    },
}
