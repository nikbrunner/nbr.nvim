local get_news = function()
    require("snacks").win({
        file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
        width = 0.6,
        height = 0.6,
        wo = {
            spell = false,
            wrap = false,
            signcolumn = "yes",
            statuscolumn = " ",
            conceallevel = 3,
        },
    })
end

---@type LazyPluginSpec
return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
        bigfile = { enabled = true },
        statuscolumn = { enabled = true },
        debug = { enabled = true },
        notifier = { enabled = true },
        toggle = { enabled = true },
        gitbrowse = { enabled = true },
        input = { enabled = true },
        -- https://github.com/folke/snacks.nvim/blob/main/lua/snacks/picker/config/defaults.lua
        picker = {
            ui_select = true, -- replace `vim.ui.select` with the snacks picker
            previewers = {
                git = {
                    native = true, -- use native (terminal) or Neovim for previewing git diffs and commits
                },
            },
            win = {
                input = {
                    keys = {
                        ["<c-t>"] = { "edit_tab", mode = { "i", "n" } },
                    },
                },
                list = {
                    keys = {
                        ["<c-t>"] = "edit_tab",
                    },
                },
            },

            sources = {
                files = {
                    layout = {
                        preset = "vscode",
                        border = "solid",
                    },
                },
                lsp_symbols = {
                    finder = "lsp_symbols",
                    format = "lsp_symbol",
                    hierarchy = true,
                    filter = {
                        default = true,
                        markdown = true,
                        help = true,
                    },
                    layout = {
                        preset = "ivy",
                    },
                },
                ---@type snacks.picker.recent.Config
                recent = {
                    layout = {
                        preset = "vscode",
                    },
                },
                diagnostics = {
                    layout = {
                        preset = "ivy",
                    },
                },
                diagnostics_buffer = {
                    layout = {
                        preset = "ivy",
                    },
                },
                git_status = {
                    preview = "git_status",
                    layout = {
                        preset = "ivy",
                    },
                },
                git_diff = {
                    layout = {
                        preset = "ivy",
                    },
                },
            },
        },

        zen = {
            toggles = {
                dim = false,
                git_signs = false,
                mini_diff_signs = false,
                -- diagnostics = false,
                -- inlay_hints = false,
            },
        },

        ---@type snacks.words.Config
        words = { debounce = 100 },

        ---@type snacks.dashboard.Config
        ---@diagnostic disable-next-line: missing-fields
        dashboard = {
            preset = {
                -- Defaults to a picker that supports `fzf-lua`, `telescope.nvim` and `mini.pick`
                ---@type fun(cmd:string, opts:table)|nil
                pick = nil,
                -- Used by the `keys` section to show keymaps.
                -- Set your curstom keymaps here.
                -- When using a function, the `items` argument are the default keymaps.
                ---@type snacks.dashboard.Item[]
                keys = {
                    { icon = " ", key = "n", desc = "New Document", action = ":ene | startinsert" },
                    {
                        icon = " ",
                        key = "<leader>wd",
                        desc = "[W]orkspace [D]ocument",
                        action = ":lua Snacks.dashboard.pick('files')",
                    },
                    {
                        icon = "󰋚 ",
                        key = "<leader>wr",
                        desc = "[W]orkspace [R]ecent Document",
                        action = ":lua require('fzf-lua').oldfiles({ cwd_only = true, prompt = 'Recent Files (CWD): '})",
                    },
                    {
                        icon = " ",
                        key = "<leader>wt",
                        desc = "[W]orkspace [T]ext",
                        action = ":lua Snacks.dashboard.pick('live_grep')",
                    },
                    {
                        icon = " ",
                        key = "<leader>as",
                        desc = "[A]pplication [S]ettings",
                        action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
                    },
                    { icon = " ", key = "s", desc = "Restore Session", section = "session" },
                    {
                        icon = "󰒲 ",
                        key = "<leader>ax",
                        desc = "Application Extentions",
                        action = ":Lazy",
                        enabled = package.loaded.lazy ~= nil,
                    },
                    { icon = " ", key = "q", desc = "Quit", action = ":qa" },
                },
                header = [[
                  ┓        •                                  
                ┏┓┣┓┏┓ ┏┓┓┏┓┏┳┓                               
                ┛┗┗┛┛ •┛┗┗┛┗┛┗┗                               
                ]],
            },

            sections = {
                { section = "header" },
                { section = "keys", gap = 1, padding = 1 },
                { pane = 2, icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
                { pane = 2, icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
                {
                    pane = 2,
                    icon = " ",
                    title = "Git Status",
                    section = "terminal",
                    enabled = vim.fn.isdirectory(".git") == 1,
                    cmd = "hub status --short --branch --renames",
                    height = 5,
                    padding = 1,
                    ttl = 5 * 60,
                    indent = 3,
                },
                { section = "startup" },
            },
        },

        terminal = {
            win = {
                border = "solid",
            },
        },

        lazygit = {
            configure = true,
            win = {
                border = "solid",
                width = 0.95,
                height = 0.9,
            },
        },

        styles = {
            notification_history = {
                border = "solid",
                wo = { winhighlight = "Normal:NormalFloat" },
            },
            notification = {
                border = "single",
            },
            zen = {
                width = 0.65,
                keys = {
                    q = function(self)
                        self:close()
                    end,
                    -- d = function(self)
                    --     require("snacks").toggle.dim()
                    -- end,
                },
            },
        },
    },

    init = function()
        local Snacks = require("snacks")

        vim.api.nvim_create_autocmd("User", {
            pattern = "VeryLazy",
            callback = function()
                -- stylua: ignore start
                Snacks.toggle.dim():map("<leader>aod")
                Snacks.toggle.line_number():map("<leader>aol")
                Snacks.toggle.inlay_hints():map("<leader>aoh")
                Snacks.toggle.diagnostics():map("<leader>aoD")
                Snacks.toggle.treesitter():map("<leader>aoT")
                Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>aoL")
                Snacks.toggle.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }):map("<leader>aoc")
                Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>aob")
                Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>aos")
                Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>aow")
                -- stylua: ignore end
            end,
        })
    end,

    keys = function()
        local Snacks = require("snacks")

        return {
            -- stylua: ignore start
            { "<leader>.",           function() Snacks.picker.resume() end, desc = "Resume Picker" },
            { "<leader>:",           function() Snacks.picker.command_history() end, desc = "Command History" },
            { "<leader>'",           function() Snacks.picker.registers() end, desc = "Registers" },
            { "<C-/>",               function() Snacks.terminal() end, desc = "Toggle Terminal" },
            { "]]",                  function() Snacks.words.jump(vim.v.count1) end, desc = "Next Reference" },
            { "[[",                  function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev Reference" },

            -- App
            { "<leader>aw",          function() Snacks.picker.zoxide() end, desc = "[W]orkspace" },
            { "<leader>aa",          function() Snacks.picker.commands() end, desc = "[A]ctions" },
            { "<leader>ag",          function() Snacks.lazygit() end, desc = "[G]it" },
            { "<leader>af",          function() Snacks.zen.zen() end, desc = "[F]ocus Mode" },
            { "<leader>as",          function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "[S]ettings" },
            { "<leader>at",          function() Snacks.picker.colorschemes() end, desc = "[T]hemes" },
            { "<leader>az",          function() Snacks.zen.zoom() end, desc = "[Z]oom Mode" },
            { "<leader>an",          function() Snacks.notifier.show_history() end, desc = "[N]otifications" },
            { "<leader>ak",          function() Snacks.picker.keymaps() end, desc = "[K]eymaps" },
            { "<leader>aj",          function() Snacks.picker.jumps() end, desc = "[J]umps" },
            { "<leader>ahp",         function() Snacks.picker.help() end, desc = "[P]ages" },
            { "<leader>ahm",         function() Snacks.picker.man() end, desc = "[M]anuals" },
            { "<leader>ahh",         function() Snacks.picker.highlights() end, desc = "[H]ightlights" },
            { "<leader>aR",          function() Snacks.gitbrowse() end, desc = "Open in [R]emote" },
            { "<leader>aN",          get_news, desc = "[N]ews",  },

            -- Workspace
            -- { "<leader>wr",          function() Snacks.picker.recent() end, desc = "[D]ocument" }, // TODO: scope to current cwd
            { "<leader>wg",          function() Snacks.lazygit() end, desc = "[G]it" },
            { "<leader>wl",          function() Snacks.lazygit.log() end, desc = "[G]it Log" },
            { "<leader>wd",          function() Snacks.picker.files() end, desc = "[D]ocument" },
            { "<leader>wt",          function() Snacks.picker.grep() end, desc = "[T]ext" },
            { "<leader>ww",          function() Snacks.picker.grep_word() end, desc = "[W]ord" },
            { "<leader>wm",          function() Snacks.picker.git_status() end, desc = "[M]odified Documents" },
            { "<leader>wc",          function() Snacks.picker.git_diff() end, desc = "[C]hanges" },
            { "<leader>wp",          function() Snacks.picker.diagnostics() end, desc = "[P]roblems" },

            -- Document
            { "<leader>dg",          function() Snacks.lazygit.log_file() end, desc = "[G]it" },
            { "<leader>dt",          function() Snacks.picker.lines() end, desc = "[T]ext" },
            { "<leader>dp",          function() Snacks.picker.diagnostics_buffer() end, desc = "[P]roblems" },
            { "<leader>ds",          function() Snacks.picker.lsp_symbols() end, desc = "[S]ymbols" },

            -- Symbol
            { "sd",                  function() Snacks.picker.lsp_definitions() end, desc = "[D]efintions" },
            { "sr",                  function() Snacks.picker.lsp_references() end, desc = "[R]eferences" },
            { "st",                  function() Snacks.picker.lsp_type_definitions() end, desc = "[T]ype Definitions" },
            { "sg",                  function() Snacks.git.blame_line() end, desc = "[G]it" },
        }
        -- stylua: ignore end
    end,
}
