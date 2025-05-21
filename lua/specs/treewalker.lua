---@type LazyPluginSpec
return {
    "aaronik/treewalker.nvim",
    event = "VeryLazy",

    -- The following options are the defaults.
    -- Treewalker aims for sane defaults, so these are each individually optional,
    -- and setup() does not need to be called, so the whole opts block is optional as well.
    opts = {
        -- Whether to briefly highlight the node after jumping to it
        highlight = true,

        -- How long should above highlight last (in ms)
        highlight_duration = 250,

        -- The color of the above highlight. Must be a valid vim highlight group.
        -- (see :h highlight-group for options)
        highlight_group = "CursorLine",

        -- Whether the plugin adds movements to the jumplist -- true | false | 'left'
        --  true: All movements more than 1 line are added to the jumplist. This is the default,
        --        and is meant to cover most use cases. It's modeled on how { and } natively add
        --        to the jumplist.
        --  false: Treewalker does not add to the jumplist at all
        --  "left": Treewalker only adds :Treewalker Left to the jumplist. This is usually the most
        --          likely one to be confusing, so it has its own mode.
        jumplist = true,
    },
    keys = {
        -- { "<C-k>", "<CMD>Treewalker Up<CR>" },
        -- { "<C-j>", "<CMD>Treewalker Down<CR>" },
        -- { "<C-h>", "<CMD>Treewalker Left<CR>" },
        -- { "<C-l>", "<CMD>Treewalker Right<CR>" },
        { "<Up>", "<CMD>Treewalker Up<CR>" },
        { "<Down>", "<CMD>Treewalker Down<CR>" },
        { "<Left>", "<CMD>Treewalker Left<CR>" },
        { "<Right>", "<CMD>Treewalker Right<CR>" },
        -- { "<C-S-k>", "<CMD>Treewalker SwapUp<CR>" },
        -- { "<C-S-j>", "<CMD>Treewalker SwapDown<CR>" },
        -- { "<C-S-h>", "<CMD>Treewalker SwapLeft<CR>" },
        -- { "<C-S-l>", "<CMD>Treewalker SwapRight<CR>" },
    },
}
