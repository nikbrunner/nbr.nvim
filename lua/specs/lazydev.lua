---@type LazyPluginSpec
return {
    "folke/lazydev.nvim",
    ft = "lua",
    dependencies = { "gonstoll/wezterm-types" },
    opts = {
        library = {
            -- See the configuration section for more details
            -- Load luvit types when the `vim.uv` word is found
            "lazy.nvim",
            "/luvit-meta/library",
            { path = "snacks.nvim", words = { "Snacks" } },
            { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            { path = "wezterm-types", mods = { "wezterm" } },
        },
    },
}
