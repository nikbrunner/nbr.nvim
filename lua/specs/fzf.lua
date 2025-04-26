local M = {}

M.winopts = {
    sm = {
        no_preview = {
            row = 0.85,
            col = 0.5,
            height = 0.20,
            -- width = 0.5,
            preview = { hidden = "hidden" },
        },
    },
    modal = {
        height = 0.9,
        width = 0.95,
        preview = {
            layout = "vertical",
            vertical = "up:75%", -- up|down:size
        },
    },
    left_corner = {
        row = 1,
        col = 0,
        height = 0.5,
        width = 0.5,
        title_pos = "left",
        preview = {
            hidden = "hidden",
            layout = "horizontal",
            vertical = "right:50%", -- up|down:size
        },
    },
    md = {
        flex = {
            height = 0.65,
            width = 0.65,
            preview = {
                layout = "flex",
                vertical = "up:50%",
            },
        },
        vertical = {
            row = 0.65,
            col = 0.5,
            height = 0.85,
            width = 0.65,
            preview = {
                layout = "vertical",
                vertical = "up:65%", -- up|down:size
            },
        },
    },
    lg = {
        flex = {
            height = 0.9,
            width = 0.9,
            preview = {
                layout = "flex",
                vertical = "up:65%", -- up|down:size
                horizontal = "left:50%", -- right|left:size
            },
        },
        vertical_corner = {
            row = 0.85,
            col = 1,
            height = 0.9,
            width = 85,
            preview = {
                layout = "vertical",
                vertical = "up:65%", -- up|down:size
            },
        },
        vertical = {
            height = 0.95,
            width = 0.95,
            preview = {
                layout = "vertical",
                vertical = "up:65%", -- up|down:size
            },
        },
    },
    fullscreen = {
        flex = {
            fullscreen = true,
            preview = {
                layout = "flex",
                vertical = "up:65%", -- up|down:size
                horizontal = "left:50%", -- right|left:size
            },
        },
        vertical = {
            fullscreen = true,
            preview = {
                layout = "vertical",
                vertical = "up:65%",
            },
        },
    },
}

function M.search_selection_with_fzf()
    -- Save the current selection to the unnamed register
    vim.cmd('normal! "vy')

    -- Get the content of the unnamed register
    local selection = vim.fn.getreg("v")

    -- Remove any leading/trailing whitespace
    selection = selection:gsub("^%s*(.-)%s*$", "%1")

    require("fzf-lua").live_grep_native({ search = selection, winopts = M.winopts.lg.vertical })
end

function M.grep_over_changed_files()
    require("fzf-lua").grep({
        raw_cmd = [[git status -su | rg "^\s*M" | cut -d ' ' -f3 | xargs rg --hidden --column --line-number --no-heading --color=always  --with-filename -e '']],
    })
end

function M.find_related_files()
    local current_filename = vim.fn.expand("%:t:r")
    local relative_filepath = vim.fn.fnamemodify(vim.fn.expand("%"), ":~:.") -- Get path relative to cwd

    require("fzf-lua").files({
        query = current_filename,
        winopts = M.winopts.sm.no_preview,
        fd_opts = string.format("--color=never --type f --hidden --follow --exclude .git --exclude %q", relative_filepath),
        fzf_opts = {
            ["--tiebreak"] = "chunk",
            ["--no-info"] = "",
        },
    })
end

M.keys = function()
    local fzfLua = require("fzf-lua")

    return {
        -- stylua: ignore start
        { "z=",               function() fzfLua.spell_suggest({ winopts = { height = 0.35, width = 0.65 } }) end, desc = "Spelling Suggestions" },
        { "<leader><tab>",    function() fzfLua.tabs() end, desc = WhichKeyIgnoreLabel },

        -- [A]pp
        { "<leader>aa",       function() fzfLua.commands({ winopts = M.winopts.md.vertical }) end, desc = "[A]ctions" },
        { "<leader>ak",       function() fzfLua.keymaps() end, desc = "[K]eybindings" },
        { "<leader>aj",       function() fzfLua.jumps({ winopts = M.winopts.md.vertical }) end, desc = "[J]umps" },
        { "<leader>at",       function() fzfLua.colorschemes() end, desc = "[T]hemes" },
        { "<leader>ar",       function() fzfLua.oldfiles({ cwd_only = false, prompt = "Recent Files (Anywhere): ", winopts = M.winopts.sm.no_preview }) end, desc = "[R]ecent Documents (across Workspaces)" },
        { "<leader>as",       function() fzfLua.files({ cwd = vim.fn.stdpath('config'), winopts = M.winopts.md.flex }) end, desc = "[S]ettings" },
        { "<leader>aht",      function() fzfLua.help_tags() end, desc = "[T]ags" },
        { "<leader>ahm",      function() fzfLua.man_pages() end, desc = "[M]an Pages" },
        { "<leader>ahh",      function() fzfLua.highlights() end, desc = "[H]ighlights" },

        -- [W]orkspace
        { "<leader>wd",       function() fzfLua.files({ winopts = M.winopts.left_corner }) end, desc = "[D]ocument" },
        { "<leader>ww",       function() fzfLua.grep_cword() end, mode = { "n", "v" }, desc = "[W]ord" },
        { "<leader>wr",       function() fzfLua.oldfiles({ cwd_only = true, prompt = "Recent Files (CWD): ", winopts = M.winopts.left_corner }) end, desc = "[R]ecent Documents" },
        { "<leader>wt",       function() fzfLua.live_grep({ winopts = M.winopts.md.vertical }) end, desc = "[T]ext" },
        { "<leader>wm",       function() fzfLua.git_status({ winopts = M.winopts.modal }) end, desc = "[M]odified Documents" },
        { "<leader>ws",       function() fzfLua.lsp_live_workspace_symbols({ winopts = M.winopts.left_corner }) end, desc = "[S]ymbol" },
        { "<leader>wvb",      function() fzfLua.git_branches() end, desc = "[B]ranches" },
        { "<leader>wvc",      function() fzfLua.git_commits() end, desc = "[C]ommits" },
        { "<leader>wvt",      function() fzfLua.git_tags() end, desc = "[T]ags" },

        -- [D]ocument
        { "<leader>da",       M.find_related_files, desc = "[A]ssociated documents", },
        { "<leader>dt",       function() fzfLua.lgrep_curbuf({ winopts = M.winopts.md.flex }) end, desc = "[T]ext" },
        { "<leader>ds",       function() fzfLua.lsp_document_symbols({ winopts = M.winopts.left_corner }) end, desc = "[S]ymbols" },
        { "<leader>dc",       function() fzfLua.changes() end, desc = "[C]hanges" },
        -- stylua: ignore end

        -- [S]ymbols
        {
            "sa",
            function()
                fzfLua.lsp_code_actions({
                    winopts = {
                        relative = "cursor",
                        row = 1,
                        col = 0,
                        height = 10,
                        width = 65,
                    },
                })
            end,
            desc = "[A]ctions",
        },
        {
            "sd",
            function()
                fzfLua.lsp_definitions({
                    jump_to_single_result = true,
                })
            end,
            desc = "[D]efinition",
        },
        {
            "st",
            function()
                fzfLua.lsp_typedefs({
                    jump_to_single_result = true,
                })
            end,
            desc = "[T]ype Definition",
        },
    }
end

M.spec = {
    "ibhagwan/fzf-lua",
    enabled = false,
    keys = M.keys,
    opts = {
        global_resume = true,
        global_resume_query = true,
        defaults = {
            formatter = "path.filename_first",
            git_icons = false,
            file_icons = false,
            color_icons = false,
        },

        winopts = {
            height = 0.85,
            width = 0.85,
            row = 0.35,
            col = 0.50,
            border = "solid",
            backdrop = 100,
            preview = {
                border = "solid", -- border|noborder, applies only to
                wrap = "nowrap", -- wrap|nowrap
                hidden = "nohidden", -- hidden|nohidden
                vertical = "up:65%", -- up|down:size
                horizontal = "right:60%", -- right|left:size
                layout = "flex", -- horizontal|vertical|flex
                flip_columns = 200, -- #cols to switch to horizontal on flex
                title = true, -- preview border title (file/buf)?
                delay = 100, -- delay(ms) displaying the preview
                winopts = { -- builtin previewer window options
                    number = false,
                    relativenumber = false,
                    cursorline = true,
                    cursorlineopt = "both",
                    cursorcolumn = false,
                    signcolumn = "no",
                    list = false,
                    foldenable = false,
                    foldmethod = "manual",
                },
            },
        },

        keymap = {
            builtin = {
                true,
                ["<C-d>"] = "preview-page-down",
                ["<C-u>"] = "preview-page-up",
            },
            fzf = {
                ["ctrl-c"] = "abort",
                ["ctrl-a"] = "toggle-all",
                ["ctrl-d"] = "preview-page-down",
                ["ctrl-u"] = "preview-page-up",
                ["ctrl-q"] = "select-all+accept",
            },
        },

        fzf_opts = {
            ["--prompt"] = "   ",
            ["--keep-right"] = "",
            ["--border-label"] = "[ nbr.nvim ]",
            ["--padding"] = "1,3",
            ["--no-scrollbar"] = "",
            ["--tiebreak"] = "index",
            ["--history"] = vim.fn.stdpath("data") .. "/fzf-lua-history",
        },

        fzf_colors = true,

        -- TODO: Try to make headers work: https://github.com/ibhagwan/fzf-lua/issues/1351#issuecomment-2265742596
        files = {
            prompt = "Files  ",
            cwd_prompt_shorten_len = 32, -- shorten prompt beyond this length
            cwd_prompt_shorten_val = 4, -- shortened path parts length
        },

        oldfiles = {
            prompt = "Recent Files  ",
            cwd_only = true,
            stat_file = true,
            include_current_session = true, -- include bufs from current session
        },

        git = {
            files = { prompt = "Git Files  " },
            status = { prompt = "Git Status  " },
        },

        grep = {
            rg_opts = "--column --line-number --no-heading --color=always --smart-case --max-columns=512 --glob=!gp/",
        },

        lsp = {
            prompt_postfix = "❯ ", -- will be appended to the LSP label
            -- to override use 'prompt' instead
            cwd_only = false, -- LSP/diagnostics for cwd only?
            async_or_timeout = 5000, -- timeout(ms) or 'true' for async calls
            file_icons = true,
            git_icons = false,
            -- The equivalent of using `includeDeclaration` in lsp buf calls, e.g:
            -- :lua vim.lsp.buf.references({includeDeclaration = false})
            includeDeclaration = true, -- include current declaration in LSP context
            -- settings for 'lsp_{document|workspace|lsp_live_workspace}_symbols'
            symbols = {
                -- lsp_query      = "foo"       -- query passed to the LSP directly
                -- query          = "bar"       -- query passed to fzf prompt for fuzzy matching
                async_or_timeout = true, -- symbols are async by default
                symbol_style = 1, -- style for document/workspace symbols
                -- false: disable,    1: icon+kind
                --     2: icon only,  3: kind only
                -- NOTE: icons are extracted from
                -- vim.lsp.protocol.CompletionItemKind
                -- icons for symbol kind
                -- see https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#symbolKind
                -- see https://github.com/neovim/neovim/blob/829d92eca3d72a701adc6e6aa17ccd9fe2082479/runtime/lua/vim/lsp/protocol.lua#L117
                symbol_icons = {
                    File = "󰈙",
                    Module = "",
                    Namespace = "󰦮",
                    Package = "",
                    Class = "󰆧",
                    Method = "󰊕",
                    Property = "",
                    Field = "",
                    Constructor = "",
                    Enum = "",
                    Interface = "",
                    Function = "󰊕",
                    Variable = "󰀫",
                    Constant = "󰏿",
                    String = "",
                    Number = "󰎠",
                    Boolean = "󰨙",
                    Array = "󱡠",
                    Object = "",
                    Key = "󰌋",
                    Null = "󰟢",
                    EnumMember = "",
                    Struct = "󰆼",
                    Event = "",
                    Operator = "󰆕",
                    TypeParameter = "󰗴",
                },
                -- colorize using Treesitter '@' highlight groups ("@function", etc).
                -- or 'false' to disable highlighting
                symbol_hl = function(s)
                    return "@" .. s:lower()
                end,
                -- additional symbol formatting, works with or without style
                symbol_fmt = function(s, opts)
                    return "[" .. s .. "]"
                end,
                -- prefix child symbols. set to any string or `false` to disable
                child_prefix = true,
                fzf_opts = { ["--tiebreak"] = "begin" },
            },
            code_actions = {
                previewer = false,
            },
        },

        highlights = {
            actions = {
                ["default"] = function(entry)
                    local hl_group = entry[1]
                    vim.fn.setreg("+", hl_group)
                    vim.notify("Copied " .. hl_group .. " to the clipboard!", vim.log.levels.INFO)
                end,
            },
        },
    },
    config = function(_, opts)
        require("fzf-lua").setup(opts)

        local config = require("fzf-lua.config")
        local actions = require("trouble.sources.fzf").actions
        config.defaults.actions.files["alt-t"] = actions.open
    end,
}

return M.spec
