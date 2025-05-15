local Config = require("config")
local UI = require("lib.ui")
local ShaDa = require("shada")

local auto = vim.api.nvim_create_autocmd

local function auto_group(name)
    return vim.api.nvim_create_augroup("nvim_" .. name, { clear = true })
end

auto("VimEnter", {
    group = auto_group("vim_enter"),
    callback = function()
        ---@diagnostic disable-next-line: undefined-field
        -- local background = vim.opt.background:get()
        local background = ShaDa.read("background")
        local colorscheme = ShaDa.read("colorscheme_" .. background)

        -- Check if colorscheme is a string
        if type(colorscheme) == "string" then
            UI.handle_colors(Config, colorscheme, background)
        end
    end,
})
--
auto("ColorScheme", {
    group = auto_group("colorscheme_sync"),
    callback = function(args)
        ---@diagnostic disable-next-line: undefined-field
        local background = vim.opt.background:get()
        local colorscheme = args.match

        ShaDa.update("colorscheme_" .. background, colorscheme)
        UI.handle_colors(Config, colorscheme, background)
    end,
})

-- Close these filetypes with <Esc> & q in normal mode
auto("FileType", {
    group = auto_group("quit_mapping"),
    pattern = {
        "nofile",
        "qf",
        "help",
        "man",
        "notify",
        "lspinfo",
        "neo-tree",
        "spectre_panel",
        "startuptime",
        "tsplayground",
        "PlenaryTestPopup",
        "diagmsg",
        "chatpgpt",
        "fzf",
        "aerial-nav",
        "dropbar_menu",
        "bmessages_buffer",
        "ftterm_lazygit",
        "ftterm_gh_dash",
    },
    callback = function(event)
        vim.bo[event.buf].buflisted = false
        vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = event.buf, silent = true })
    end,
})

-- go to last loc when opening a buffer
auto("BufReadPost", {
    group = auto_group("last_loc"),
    callback = function(event)
        local exclude = { "gitcommit" }
        local buf = event.buf
        if vim.list_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then
            return
        end
        vim.b[buf].lazyvim_last_loc = true
        local mark = vim.api.nvim_buf_get_mark(buf, '"')
        local lcount = vim.api.nvim_buf_line_count(buf)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

-- Check if we need to reload the file when it changed
auto({ "BufEnter", "FocusGained", "TermClose", "TermLeave" }, {
    group = auto_group("checktime"),
    callback = function()
        vim.cmd("checktime")
        local ok, gitsigns = pcall(require, "gitsigns")
        if ok then
            gitsigns.refresh()
        end
    end,
})

-- Highlight on yank
auto("TextYankPost", {
    group = auto_group("highlight_yank"),
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- resize splits if window got resized
auto({ "VimResized" }, {
    group = auto_group("resize_splits"),
    callback = function()
        local current_tab = vim.fn.tabpagenr()
        vim.cmd("tabdo wincmd =")
        vim.cmd("tabnext " .. current_tab)
    end,
})

-- Set a color column, hard wrap, and other sensible options for gitcommit buffers
auto({ "BufEnter" }, {
    group = auto_group("gitcommit"),
    callback = function()
        local max_line_width = 72 -- Git recommends 72 characters for commit messages
        if vim.bo.filetype == "gitcommit" then
            vim.opt_local.colorcolumn = tostring(max_line_width)
            vim.opt_local.textwidth = max_line_width
            vim.opt_local.wrap = true
            vim.opt_local.spell = true
        end
    end,
})
-- Close buffers when they are no longer valid
auto("FocusGained", {
    callback = function()
        local closedBuffers = {}
        vim.iter(vim.api.nvim_list_bufs())
            :filter(function(bufnr)
                local valid = vim.api.nvim_buf_is_valid(bufnr)
                local loaded = vim.api.nvim_buf_is_loaded(bufnr)
                return valid and loaded
            end)
            :filter(function(bufnr)
                local bufPath = vim.api.nvim_buf_get_name(bufnr)
                ---@diagnostic disable-next-line: undefined-field
                local doesNotExist = vim.uv.fs_stat(bufPath) == nil
                local notSpecialBuffer = vim.bo[bufnr].buftype == ""
                local notNewBuffer = bufPath ~= ""
                return doesNotExist and notSpecialBuffer and notNewBuffer
            end)
            :each(function(bufnr)
                local bufName = vim.fs.basename(vim.api.nvim_buf_get_name(bufnr))
                table.insert(closedBuffers, bufName)
                vim.api.nvim_buf_delete(bufnr, { force = true })
            end)
        if #closedBuffers == 0 then
            return
        end

        if #closedBuffers == 1 then
            vim.notify("Buffer closed" .. closedBuffers[1])
        else
            local text = "- " .. table.concat(closedBuffers, "\n- ")
            vim.notify("Buffers closed" .. text)
        end
    end,
})

auto("LspProgress", {
    ---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
    callback = function(ev)
        local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
        vim.notify(vim.lsp.status(), vim.log.levels.INFO, {
            id = "lsp_progress",
            title = "LSP Progress",
            opts = function(notif)
                notif.icon = ev.data.params.value.kind == "end" and " "
                    ---@diagnostic disable-next-line: undefined-field
                    or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
            end,
        })
    end,
})
