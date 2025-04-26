local patterns = {
    { pattern = "add braces", key = "a", order = 1 },
    { pattern = "add import", key = "i", order = 1 },
    { pattern = "global dictionary", key = "g", order = 2 },
    { pattern = "file dictionary", key = "f", order = 3 },
    { pattern = "ignore", key = "i", order = 1 },
}
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
            javascript = patterns,
            typescript = patterns,
            javascriptreact = patterns,
            typescriptreact = patterns,
            lua = patterns,
        },
    },
    keys = {
        {
            "sa",
            function()
                require("fastaction").code_action()
            end,
            desc = "[A]ction",
        },
        {
            "sa",
            mode = "v",
            function()
                require("fastaction").range_code_action()
            end,
            desc = "[A]ction",
        },
    },
}
