---@type LazyPluginSpec
return {
    "jackplus-xyz/player-one.nvim",
    event = "VeryLazy",
    ---@module "player-one"
    ---@type PlayerOne.Config
    opts = {
        theme = "chiptune",
    },
}
