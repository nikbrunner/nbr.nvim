---@type LazyPluginSpec
return {
    "Chaitanyabsprip/fastaction.nvim",
    event = "BufRead",
    enabled = false,
    ---@module "fastaction"
    ---@type FastActionConfig
    opts = {
        dismiss_keys = { "j", "k", "<c-c>", "q" },
        keys = "qwertyuiopasdfghlzxcvbnm",
        enabled = false,
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
            "<leader>sa",
            function()
                require("fastaction").code_action()
            end,
            desc = "[A]ction",
        },
        {
            "<leader>sa",
            mode = "v",
            function()
                require("fastaction").range_code_action()
            end,
            desc = "[A]ction",
        },
    },
}
