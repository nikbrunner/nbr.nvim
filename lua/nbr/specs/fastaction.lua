local js_like_patterns = {
    { pattern = "add braces", key = "a", order = 1 },
    { pattern = "add import", key = "i", order = 1 },
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
            javascript = js_like_patterns,
            typescript = js_like_patterns,
            javascriptreact = js_like_patterns,
            typescriptreact = js_like_patterns,
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
