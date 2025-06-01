local M = {}

---@type LazyPluginSpec[]
M.specs = {
    {
        "echasnovski/mini.surround",
        version = "*",
        event = "VeryLazy",
        opts = {
            mappings = {
                add = "Sa", -- Add surrounding in Normal and Visual modes
                delete = "Sd", -- Delete surrounding
                find = "Sf", -- Find surrounding (to the right)
                find_left = "SF", -- Find surrounding (to the left)
                highlight = "Sh", -- Highlight surrounding
                replace = "Sr", -- Replace surrounding
                update_n_lines = "Sn", -- Update `n_lines`
            },
        },
    },

    { "echasnovski/mini.ai", version = "*", event = "VeryLazy", opts = {} },

    { "echasnovski/mini.pairs", version = "*", event = "VeryLazy", opts = {}, enabled = false },

    {
        "echasnovski/mini.statusline",
        lazy = false,
        opts = function()
            return {
                content = {
                    active = function()
                        local m = require("mini.statusline")

                        local fnamemodify = vim.fn.fnamemodify

                        local project_name = function()
                            local current_project_folder = fnamemodify(vim.fn.getcwd(), ":t")
                            local parent_project_folder = fnamemodify(vim.fn.getcwd(), ":h:t")
                            return parent_project_folder .. "/" .. current_project_folder
                        end

                        local lazy_plug_count = function()
                            local stats = require("lazy").stats()
                            return " " .. stats.count
                        end

                        local lazy_startup = function()
                            local stats = require("lazy").stats()
                            local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
                            return " " .. ms .. "ms"
                        end

                        local lazy_updates = function()
                            return require("lazy.status").updates()
                        end

                        local word_count = function()
                            if vim.bo.filetype == "markdown" then
                                local words = vim.fn.wordcount().words
                                return " " .. words .. "w"
                            end
                            return ""
                        end

                        local mode, mode_hl = m.section_mode({ trunc_width = 120 })

                        local git = m.section_git({ trunc_width = 75 })

                        local relative_filepath = function()
                            local current_cols = vim.fn.winwidth(0)
                            if current_cols > 120 then
                                return vim.fn.fnamemodify(vim.fn.expand("%"), ":~:.") -- Filename with relative path
                            else
                                return vim.fn.expand("%:t") -- Just the filename
                            end
                        end

                        local diagnostics = m.section_diagnostics({ trunc_width = 75 })
                        local viewport = "󰊉 " .. vim.o.lines .. ":W" .. vim.o.columns
                        local position = "󰩷 " .. vim.fn.line(".") .. ":" .. vim.fn.col(".")
                        local filetype = " " .. vim.bo.filetype

                        local black_atom_label = nil
                        local black_atom_meta = require("black-atom.api").get_meta()

                        if black_atom_meta then
                            black_atom_label = black_atom_meta.label
                        end
                        local colorscheme_name = black_atom_label or vim.g.colors_name or "default"
                        local colorscheme = m.is_truncated(200) and "" or " " .. colorscheme_name

                        local dev_mode = m.is_truncated(125) and ""
                            or "DEV_MODE: " .. (require("shada").read().dev_mode and "ON" or "OFF")

                        return m.combine_groups({
                            { hl = mode_hl, strings = { mode } },
                            {
                                hl = "@function",
                                strings = (m.is_truncated(100) and {} or { project_name() }),
                            },
                            {
                                hl = "@variable.member",
                                strings = (m.is_truncated(200) and {} or { git }),
                            },

                            "%<", -- Mark general truncate point

                            { hl = "DiagnosticError", strings = { diagnostics } },

                            "%=", -- End left alignment

                            {
                                hl = "@function",
                                strings = { dev_mode, word_count(), position, viewport, filetype },
                            },
                            {
                                hl = "Comment",
                                strings = (m.is_truncated(165) and {} or {
                                    lazy_plug_count(),
                                    lazy_updates(),
                                    lazy_startup(),
                                    colorscheme,
                                    "[" .. vim.o.background .. "]",
                                }),
                            },
                        })
                    end,
                },
            }
        end,
        config = function(_, opts)
            require("mini.statusline").setup(opts)
            vim.opt.laststatus = 3
        end,
    },

    {
        "echasnovski/mini.icons",
        event = "VeryLazy",
        opts = {
            file = {
                [".eslintrc.js"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
                [".node-version"] = { glyph = "", hl = "MiniIconsGreen" },
                [".prettierrc"] = { glyph = "", hl = "MiniIconsPurple" },
                [".yarnrc.yml"] = { glyph = "", hl = "MiniIconsBlue" },
                ["eslint.config.js"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
                ["package.json"] = { glyph = "", hl = "MiniIconsGreen" },
                ["tsconfig.json"] = { glyph = "", hl = "MiniIconsAzure" },
                ["tsconfig.build.json"] = { glyph = "", hl = "MiniIconsAzure" },
                ["yarn.lock"] = { glyph = "", hl = "MiniIconsBlue" },
            },
        },
        init = function()
            -- QUESTION: why, and how long is this needed?
            package.preload["nvim-web-devicons"] = function()
                -- needed since it will be false when loading and mini will fail
                package.loaded["nvim-web-devicons"] = {}
                require("mini.icons").mock_nvim_web_devicons()
                return package.loaded["nvim-web-devicons"]
            end
        end,
    },
}

return M.specs
