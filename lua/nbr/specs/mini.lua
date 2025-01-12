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

    { "echasnovski/mini.pairs", version = "*", event = "VeryLazy", opts = {} },

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

                        local mode, mode_hl = m.section_mode({ trunc_width = 120 })

                        local git = m.section_git({ trunc_width = 75 })
                        local diagnostics = m.section_diagnostics({ trunc_width = 75 })
                        local colorscheme_name = vim.g.colors_name or "default"
                        local colorscheme = m.is_truncated(200) and "" or " " .. colorscheme_name

                        return m.combine_groups({
                            { hl = mode_hl, strings = { mode } },
                            {
                                hl = "@function",
                                strings = { project_name() },
                            },
                            {
                                hl = "@variable.member",
                                strings = { git },
                            },

                            "%<", -- Mark general truncate point

                            { hl = "DiagnosticError", strings = { diagnostics } },

                            "%=", -- End left alignment

                            {
                                hl = "Comment",
                                strings = (m.is_truncated(165) and {} or {
                                    lazy_plug_count(),
                                    lazy_updates(),
                                    lazy_startup(),
                                    colorscheme,
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
