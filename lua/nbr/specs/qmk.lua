local M = {}

---@type LazyPluginSpec
M.spec = {
    "codethread/qmk.nvim",
    ft = "c",
    event = "VeryLazy",
    opts = {
        comment_preview = {
            position = "inside",
            keymap_overrides = {
                KC_TRANSPARENT = " ",
                ["SS_TILD_SLSH"] = "~/",
                ["SS_FATARROW"] = "=>",
                ["SS_VIM_WA"] = ":wa",
                ["SS_TODO"] = "TODO",
                ["SS_BCD"] = "BCD-",
            },
        },
    },
    config = function(_, sharedOpts)
        local setup = function(opts)
            local mergedOpts = vim.tbl_deep_extend("force", sharedOpts, opts or {})
            require("qmk").setup(mergedOpts)
        end

        local group = vim.api.nvim_create_augroup("qmk-auto-format-group", {})

        vim.api.nvim_create_autocmd("BufEnter", {
            desc = "Format CRKBD koyo keymap",
            group = group,
            pattern = "*nikbrunner/koyo/qmk/crkbd/src/keymap.c",
            callback = function()
                setup({
                    name = "LAYOUT_split_3x5_3",
                    layout = {
                        "x x x x x _ x x x x x",
                        "x x x x x _ x x x x x",
                        "x x x x x _ x x x x x",
                        "_ _ x x x _ x x x _ _",
                    },
                })
            end,
        })

        vim.api.nvim_create_autocmd("BufEnter", {
            desc = "Format Moonlander koyo keymap",
            group = group,
            pattern = "*nikbrunner/koyo/qmk/moonlander/src/keymap.c",
            callback = function()
                setup({
                    name = "LAYOUT_moonlander",
                    layout = {
                        "x x x x x x x _ x x x x x x x",
                        "x x x x x x x _ x x x x x x x",
                        "x x x x x x x _ x x x x x x x",
                        "x x x x x x _ _ _ x x x x x x",
                        "x x x x x x _ _ _ x x x x x x",
                        "_ _ _ _ x x x _ x x x _ _ _ _",
                    },
                })
            end,
        })
    end,
}

return M.spec
