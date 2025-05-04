---@type LazyPluginSpec
return {
    "nikbrunner/file-surfer.nvim",
    dir = require("lib.config").get_repo_path("nikbrunner/file-surfer.nvim"),
    enabled = false,
    pin = true,
    dependencies = { "ibhagwan/fzf-lua" },
    event = "VeryLazy",
    ---@module "file-surfer"
    ---@type file-surfer.Config
    opts = {
        change_dir = false,
        tmux = {
            enable = true,
            default_mappings = false,
        },
        paths = {
            static = {
                ["~/.scripts"] = vim.fn.expand("$HOME") .. "/.scripts",
                ["dcd-rest"] = vim.fn.expand("$HOME") .. "/repos/nikbrunner/dcd-notes/http",
            },
            dynamic = {
                {
                    path = vim.fn.expand("~/repos"),
                    scan_depth = 2,
                    use_git = true,
                },
                {
                    path = vim.fn.expand("$XDG_CONFIG_HOME"),
                    scan_depth = 1,
                },
            },
        },
    },
    keys = {
        {
            -- NOTE: This is not really a workspace switcher
            "<leader>ad",
            function()
                require("file-surfer").find()
            end,
            desc = "[D]ocument (across Workspaces)",
        },
    },
}
