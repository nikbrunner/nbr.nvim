---@diagnostic disable: assign-type-mismatch, missing-fields
local M = {}

function EditLineFromLazygit(file_path, line)
    local path = vim.fn.expand("%:p")
    if path == file_path then
        vim.cmd(tostring(line))
    else
        vim.cmd("e " .. file_path)
        vim.cmd(tostring(line))
    end
end

function EditFromLazygit(file_path)
    local path = vim.fn.expand("%:p")
    if path == file_path then
        return
    else
        vim.cmd("e " .. file_path)
    end
end

function M.get_news()
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

function M.file_surfer()
    Snacks.picker.zoxide({
        confirm = function(picker, item)
            local cwd = item._path

            picker:close()
            vim.fn.chdir(cwd)

            if item then
                vim.schedule(function()
                    Snacks.picker.files({
                        filter = {
                            cwd = cwd,
                        },
                    })
                end)
            end
        end,
    })
end

function M.find_associated_files()
    local current_filename = vim.fn.expand("%:t:r")
    local relative_filepath = vim.fn.fnamemodify(vim.fn.expand("%"), ":~:.") -- Get path relative to cwd

    Snacks.picker.files({
        pattern = current_filename,
        exclude = {
            ".git",
            relative_filepath,
        },
    })
end

function M.explorer()
    local explorer_pickers = Snacks.picker.get({ source = "explorer" })
    for _, v in pairs(explorer_pickers) do
        if v:is_focused() then
            v:close()
        else
            v:focus()
        end
    end
    if #explorer_pickers == 0 then
        Snacks.picker.explorer()
    end
end

--- https://github.com/folke/snacks.nvim/blob/main/lua/snacks/picker/config/defaults.lua
--- https://github.com/folke/snacks.nvim/blob/main/lua/snacks/picker/config/sources.lua
--- https://github.com/kaiphat/dotfiles/blob/master/nvim/lua/plugins/snacks.lua

---@type LazyPluginSpec
return {
    "folke/snacks.nvim",
    priority = 1000,
    pin = false,
    lazy = false,
    ---@type snacks.Config
    opts = {
        bigfile = { enabled = true },
        statuscolumn = { enabled = true },
        debug = { enabled = true },
        notifier = {
            enabled = true,
            margin = { top = 0, right = 0, bottom = 1, left = 1 },
            top_down = false,
            style = "minimal",
        },
        toggle = { enabled = true },
        gitbrowse = { enabled = true },
        input = { enabled = true },
        scroll = { enabled = false },
        -- https://github.com/folke/snacks.nvim/blob/main/lua/snacks/picker/config/defaults.lua
        picker = {
            ui_select = true, -- replace `vim.ui.select` with the snacks picker
            matcher = {
                -- the bonusses below, possibly require string concatenation and path normalization,
                -- so this can have a performance impact for large lists and increase memory usage
                cwd_bonus = true, -- give bonus for matching files in the cwd
                frecency = true, -- frecency bonus
            },
            formatters = {
                file = {
                    filename_first = false, -- display filename before the file path
                    truncate = 80,
                },
            },
            previewers = {
                git = {
                    native = true, -- use native (terminal) or Neovim for previewing git diffs and commits
                },
            },
            layouts = {
                default = {
                    layout = {
                        box = "vertical",
                        width = 0.9,
                        min_width = 120,
                        height = 0.8,
                        {
                            box = "vertical",
                            border = "solid",
                            title = "{title} {live} {flags}",
                            { win = "input", height = 1, border = "bottom" },
                            { win = "list", border = "none" },
                        },
                        { win = "preview", title = "{preview}", border = "solid" },
                    },
                },
                ivy = {
                    layout = {
                        box = "vertical",
                        backdrop = false,
                        row = -1,
                        width = 0,
                        height = 0.4,
                        border = "solid",
                        title = " {title} {live} {flags}",
                        title_pos = "left",
                        { win = "input", height = 1, border = "bottom" },
                        {
                            box = "horizontal",
                            { win = "list", border = "none" },
                            { win = "preview", title = "{preview}", width = 0.6, border = "left" },
                        },
                    },
                },
                column = {
                    preview = "main",
                    layout = {
                        position = "float",
                        width = 60,
                        min_width = 60,
                        height = 0.80,
                        min_height = 25,
                        box = "vertical",
                        border = "solid",
                        title = "{title} {live} {flags}",
                        title_pos = "center",
                        { win = "input", height = 1, border = "bottom" },
                        { win = "list", border = "none" },
                        { win = "preview", title = "{preview}", width = 0.6, border = "left" },
                    },
                },
                flow = {
                    preview = "main",
                    layout = {
                        backdrop = false,
                        -- col = 0,
                        width = 0.65,
                        min_width = 50,
                        row = 0.65,
                        height = 0.30,
                        min_height = 10,
                        box = "vertical",
                        border = "solid",
                        title = "{title} {live} {flags}",
                        title_pos = "center",
                        { win = "preview", title = "{preview}", width = 0.6, border = "left" },
                        { win = "input", height = 1, border = "solid" },
                        { win = "list", border = "none" },
                    },
                },
                sidebar_right = {
                    preview = "main",
                    layout = {
                        backdrop = false,
                        width = 40,
                        min_width = 40,
                        height = 0,
                        position = "right",
                        border = "none",
                        box = "vertical",
                        {
                            win = "input",
                            height = 1,
                            border = "rounded",
                            title = "{title} {live} {flags}",
                            title_pos = "center",
                        },
                        { win = "list", border = "none" },
                        { win = "preview", title = "{preview}", height = 0.4, border = "top" },
                    },
                },
            },

            actions = {
                flash = function(picker)
                    require("flash").jump({
                        pattern = "^",
                        label = { after = { 0, 0 } },
                        search = {
                            mode = "search",
                            exclude = {
                                function(win)
                                    return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "snacks_picker_list"
                                end,
                            },
                        },
                        -- TODO: would be cool if it would select and confirm the picked entry, and does not require an additional enter press
                        action = function(match)
                            local idx = picker.list:row2idx(match.pos[1])
                            picker.list:_move(idx, true, true)
                        end,
                    })
                end,
            },

            win = {
                preview = {
                    wo = {
                        number = false,
                    },
                },
                input = {
                    keys = {
                        ["<c-t>"] = { "edit_tab", mode = { "i", "n" } },
                        ["<c-u>"] = { "preview_scroll_up", mode = { "i", "n" } },
                        ["<c-d>"] = { "preview_scroll_down", mode = { "i", "n" } },
                        ["<c-f>"] = { "flash", mode = { "n", "i" } },
                    },
                },
                list = {
                    keys = {
                        ["<c-t>"] = "edit_tab",
                    },
                },
            },

            sources = {
                select = {
                    layout = { preset = "flow" },
                },
                explorer = {
                    replace_netrw = true,
                    git_status = true,
                    jump = {
                        close = false,
                    },
                    hidden = true,
                    ignored = true,
                    layout = {
                        preset = "sidebar",
                        preview = {
                            main = true,
                            enabled = false,
                        },
                    },
                    win = {
                        list = {
                            keys = {
                                ["]c"] = "explorer_git_next",
                                ["[c"] = "explorer_git_prev",
                            },
                        },
                    },
                    icons = {
                        tree = {
                            vertical = "  ",
                            middle = "  ",
                            last = "  ",
                        },
                    },
                },
                buffers = {
                    current = false,
                },
                files = {
                    hidden = true,
                    layout = {
                        preset = "flow",
                        border = "solid",
                    },
                },
                smart = {
                    layout = { preset = "flow" },
                    -- multi = { "recent", "files" },
                },
                ---TODO: filter out empty file
                ---@type snacks.picker.recent.Config
                recent = {
                    layout = { preset = "flow" },
                },
                lines = {
                    layout = { preset = "flow" },
                },
                lsp_references = {
                    pattern = "!import !default", -- Exclude Imports and Default Exports
                    layout = { preset = "flow" },
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
                    layout = { preset = "flow" },
                },
                lsp_workspace_symbols = {
                    layout = { preset = "flow" },
                },
                diagnostics = {
                    layout = { preset = "flow" },
                },
                diagnostics_buffer = {
                    layout = { preset = "flow" },
                },
                git_status = {
                    preview = "git_status",
                    layout = { preset = "flow" },
                },
                git_diff = {
                    layout = { preset = "flow" },
                },
                ---@type snacks.picker.projects.Config: snacks.picker.Config
                projects = {
                    finder = "recent_projects",
                    format = "file",
                    dev = {
                        "~/repos/nikbrunner/",
                        "~/repos/dealercenter-digital/",
                        "~/repos/black-atom-industries/",
                        "~/repos/bradtraversy/",
                        "~/repos/total-typescript/",
                        "~/.local/share/nvim/lazy/",
                    },
                },
            },
        },

        zen = {
            toggles = {
                dim = true,
                git_signs = false,
                mini_diff_signs = false,
                diagnostics = true,
            },
            ---@type snacks.zen.Config
            zoom = {
                show = { statusline = false, tabline = false },
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
                -- {
                --     pane = 2,
                --     icon = " ",
                --     title = "Git Status",
                --     section = "terminal",
                --     enabled = vim.fn.isdirectory(".git") == 1,
                --     cmd = "hub status --short --branch --renames",
                --     height = 5,
                --     padding = 1,
                --     ttl = 5 * 60,
                --     indent = 3,
                -- },
                { section = "startup" },
            },
        },

        terminal = {
            win = {
                border = "solid",
                wo = {
                    winbar = "",
                },
            },
        },

        lazygit = {
            configure = true,
            config = {
                os = {
                    edit = "nvim --server $NVIM --remote-send '<cmd>close<cr><cmd>lua EditFromLazygit({{filename}})<CR>'",
                    editAtLine = "nvim --server $NVIM --remote-send '<cmd>close<CR><cmd>lua EditLineFromLazygit({{filename}},{{line}})<CR>'",
                },
            },
            win = {
                border = "solid",
                width = 0.95,
                height = 0.9,
            },
        },

        styles = {
            notification_history = {
                border = "solid",
            },
            notification = {
                border = "single",
                wo = {
                    winblend = 0,
                    winhighlight = "Normal:SnacksNotifierHistory",
                },
            },
            zen = {
                width = 0.65,
                backdrop = {
                    transparent = true,
                    blend = 20,
                },
                wo = {
                    number = false,
                    scrolloff = 999,
                },
                keys = {
                    q = function(self)
                        self:close()
                    end,
                    ["<leader>td"] = function()
                        if vim.g.snacks_animate_dim then
                            Snacks.dim.disable()
                            vim.g.snacks_animate_dim = false
                        else
                            Snacks.dim.enable()
                            vim.g.snacks_animate_dim = true
                        end
                    end,
                },
            },
        },
    },

    init = function()
        -- vim.api.nvim_create_autocmd("BufEnter", {
        --     group = vim.api.nvim_create_augroup("snacks_explorer_start_directory", { clear = true }),
        --     desc = "Start Snacks Explorer with directory",
        --     once = true,
        --     callback = function()
        --         local dir = vim.fn.argv(0) --[[@as string]]
        --         if dir ~= "" and vim.fn.isdirectory(dir) == 1 then
        --             Snacks.picker.explorer({ cwd = dir })
        --         end
        --     end,
        -- })

        vim.api.nvim_create_autocmd("User", {
            pattern = "VeryLazy",
            callback = function()
                -- stylua: ignore start
                Snacks.toggle.dim():map("<leader>aod")
                Snacks.toggle.line_number():map("<leader>aol")
                Snacks.toggle.inlay_hints():map("<leader>aoh")
                -- Snacks.toggle.diagnostics():map("<leader>aoD")
                Snacks.toggle.treesitter():map("<leader>aoT")
                Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>aoL")
                Snacks.toggle.option("conceallevel", { off = 0, on = vim.o.conceallevel > 1 and vim.o.conceallevel or 3 }):map("<leader>aoc")
                Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>aob")
                Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>aos")
                Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>aow")
                -- stylua: ignore end
            end,
        })
    end,

    keys = function()
        return {
            -- stylua: ignore start
            { "<leader>.",           function() Snacks.picker.resume() end, desc = "Resume Picker" },
            { "<leader>:",           function() Snacks.picker.command_history() end, desc = "Command History" },
            { "<leader>'",           function() Snacks.picker.registers() end, desc = "Registers" },
            { "<C-/>",               function() Snacks.terminal() end, desc = "Toggle Terminal" },
            { "]]",                  function() Snacks.words.jump(vim.v.count1) end, desc = "Next Reference" },
            { "[[",                  function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev Reference" },
            { "<F6>",                function() Snacks.dashboard.open() end, desc = "Dashboard" },

            -- App
            { "<leader>aw",          function() Snacks.picker.projects() end, desc = "[W]orkspace" },
            { "<leader>aW",          function() Snacks.picker.zoxide() end, desc = "[W]orkspace (Zoxide)" },
            { "<leader>aa",          function() Snacks.picker.commands() end, desc = "[A]ctions" },
            { "<leader>ag",          function() Snacks.lazygit() end, desc = "[G]it" },
            { "<leader>af",          function() Snacks.zen.zen() end, desc = "[F]ocus Mode" },
            { "<leader>as",          function() Snacks.picker.files({ cwd = vim.fn.expand("$HOME") .. "/repos/nikbrunner/dots" }) end, desc = "[S]ettings" },
            { "<leader>ad",          M.file_surfer, desc = "[D]ocument" },
            -- { "<leader>aS",          function() Snacks.picker.files({ cwd = vim.fn.expand("$XDG_CONFIG_HOME") }) end, desc = "[S]ettings (.config)" },
            { "<leader>at",          function() Snacks.picker.colorschemes() end, desc = "[T]hemes" },
            { "<leader>ar",          function() Snacks.picker.recent() end, desc = "[R]ecent Documents (Anywhere)" },
            { "<leader>aoz",          function() Snacks.zen.zoom() end, desc = "[Z]oom Mode" },
            { "<leader>an",          function() Snacks.notifier.show_history() end, desc = "[N]otifications" },
            { "<leader>ak",          function() Snacks.picker.keymaps() end, desc = "[K]eymaps" },
            { "<leader>aj",          function() Snacks.picker.jumps() end, desc = "[J]umps" },
            { "<leader>ahp",         function() Snacks.picker.help() end, desc = "[P]ages" },
            { "<leader>ahm",         function() Snacks.picker.man() end, desc = "[M]anuals" },
            { "<leader>ahh",         function() Snacks.picker.highlights() end, desc = "[H]ightlights" },
            { "<leader>aR",          function() Snacks.gitbrowse() end, desc = "Open in [R]emote" },
            { "<leader>aN",          M.get_news, desc = "[N]ews",  },

            -- Workspace
            { "<leader>we",          M.explorer, desc = "[E]xplorer" },
            { "<leader>wg",          function() Snacks.lazygit() end, desc = "[G]it" },
            { "<leader>wl",          function() Snacks.lazygit.log() end, desc = "[G]it Log" },
            { "<leader>wd",          function() Snacks.picker.smart() end, desc = "[D]ocument" },
            { "<C-e>",               function() Snacks.picker.smart({ filter = { cwd = true }}) end, desc = "[D]ocument" },
            { "<C-r>",               function() Snacks.picker.recent({ filter = { cwd = true }}) end, desc = "[R]ecent Documents" },
            { "<leader>wr",          function() Snacks.picker.recent({ filter = { cwd = true }}) end, desc = "[R]ecent Documents" },
            { "<leader>wt",          function() Snacks.picker.grep() end, desc = "[T]ext" },
            { "<leader>ww",          function() Snacks.picker.grep_word() end, desc = "[W]ord" },
            { "<leader>wm",          function() Snacks.picker.git_status() end, desc = "[M]odified Documents" },
            { "<leader>wc",          function() Snacks.picker.git_diff() end, desc = "[C]hanges" },
            { "<leader>wp",          function() Snacks.picker.diagnostics() end, desc = "[P]roblems" },
            { "<leader>ws",          function() Snacks.picker.lsp_workspace_symbols() end, desc = "[S]ymbols" },
            { "<leader>wvb",         function() Snacks.picker.git_branches() end, desc = "[B]ranches" },

            -- TODO: <leader>dc [D]ocument [C]hanges -- git_diff but scope on current file
            -- Document
            { "<leader>dg",          function() Snacks.lazygit.log_file() end, desc = "[G]it" },
            { "<leader>dt",          function() Snacks.picker.lines() end, desc = "[T]ext" },
            { "<leader>dp",          function() Snacks.picker.diagnostics_buffer() end, desc = "[P]roblems" },
            { "<leader>ds",          function() Snacks.picker.lsp_symbols() end, desc = "[S]ymbols" },
            { "<leader>du",          function() Snacks.picker.undo() end, desc = "[U]ndo" },
            { "<leader>da",          M.find_associated_files, desc = "[A]ssociated Documents" },

            -- Document

            -- Symbol
            { "sd",                  function() Snacks.picker.lsp_definitions() end, desc = "[D]efintions" },
            { "sr",                  function() Snacks.picker.lsp_references() end, desc = "[R]eferences" },
            { "st",                  function() Snacks.picker.lsp_type_definitions() end, desc = "[T]ype Definitions" },
            { "sg",                  function() Snacks.git.blame_line() end, desc = "[G]it" },
        }
        -- stylua: ignore end
    end,
}
