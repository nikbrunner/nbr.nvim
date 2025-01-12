---@type LazyPluginSpec
return {
    "nvchad/minty",
    dependencies = { "nvchad/volt" },
    cmd = { "Shades", "Huefy" },
    opts = {
        huefy = {

            mappings = function(buf)
                local api = require("minty.shades.api")
                vim.keymap.set("n", "<C-s>", api.save_color, { buffer = buf })
            end,
        },

        shades = {
            mappings = function(buf)
                local api = require("minty.shades.api")
                vim.keymap.set("n", "<C-s>", api.save_color, { buffer = buf })
            end,
        },
    },
}
