---@diagnostic disable: undefined-field
local lib = require("nbr.lib")

local function map(mode, lhs, rhs, opts)
    opts = opts or {}
    opts.noremap = opts.noremap == nil and true or opts.noremap
    opts.silent = opts.silent == nil and true or opts.silent
    vim.keymap.set(mode, lhs, rhs, opts)
end

map("n", "Q", "<nop>")
map("n", "s", "<Nop>")

map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")

map("n", "H", vim.cmd.tabprevious, { desc = "Previous Tab" })
map("n", "L", vim.cmd.tabnext, { desc = "Next Tab" })

map({ "n", "x" }, "<leader><leader>", function()
    vim.api.nvim_feedkeys(":", "n", true)
end, { desc = "Command Mode" })

map("n", "<Esc>", function()
    vim.cmd.nohlsearch()
    vim.cmd.wa()
    require("snacks.notifier").hide()
end, { desc = "Escape and clear hlsearch" })

map("n", "<S-Esc>", function()
    require("snacks.notifier").hide()
    lib.ui.close_all_floating_windows()
end, { desc = "Clear Notifier and Trouble" })

map("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit Terminal" })

map("n", "<C-o>", "<C-o>zz", { desc = "Move back in jump list" })
map("n", "<C-i>", "<C-i>zz", { desc = "Move forward in jump list" })

for i = 1, 9 do
    map("n", "<leader>" .. i, function()
        local existing_tab_count = vim.fn.tabpagenr("$")

        if existing_tab_count < i then
            vim.cmd("tablast")
            vim.cmd("tabnew")
        else
            vim.cmd(i .. "tabnext")
        end
    end, { desc = WhichKeyIgnoreLabel })
end

map("n", "yc", function()
    local col = vim.fn.col(".")
    vim.cmd("norm yy")
    vim.cmd("norm gcc")
    vim.cmd("norm p")
    vim.fn.cursor(vim.fn.line("."), col)
end, { desc = "Dupe line (Comment out old one)" })

map("n", "yp", function()
    local col = vim.fn.col(".")
    vim.cmd("norm yy")
    vim.cmd("norm p")
    vim.fn.cursor(vim.fn.line("."), col)
end, { desc = "Duplicate line" })

map("n", "x", '"_x', { desc = "Delete without yanking" })

-- Join lines while keeping position
map("n", "J", "mzJ`z", { desc = "Join Lines" })

map("n", "<leader>dl", "<cmd>e #<cr>", { desc = "[L]ast document" })

map("n", "<C-c>", "ciw")

-- Resize splits with shift + arrow
map({ "n", "v", "x" }, "<S-Down>", "<cmd>resize -2<cr>", { desc = "Resize Split Down" })
map({ "n", "v", "x" }, "<S-Up>", "<cmd>resize +2<cr>", { desc = "Resize Split Up" })

map({ "n", "v", "x" }, "<S-Right>", "<cmd>vertical resize -5<cr>", { desc = "Resize Split Left" })
map({ "n", "v", "x" }, "<S-Left>", "<cmd>vertical resize +5<cr>", { desc = "Resize Split Right" })

-- Better up/down
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- indenting and reselect
map("v", "<", "<gv")
map("v", ">", ">gv")

map("i", ",", ",<c-g>u")
map("i", ".", ".<c-g>u")
map("i", ";", ";<c-g>u")

-- Center screen when using <C-u> and <C-d>
map({ "n", "i", "c" }, "<C-u>", "<C-u>zz", { desc = "Scroll Up" })
map({ "n", "i", "c" }, "<C-d>", "<C-d>zz", { desc = "Scroll Down" })

-- prev/next
map("n", "[q", vim.cmd.cprev, { desc = "Previous quickfix" })
map("n", "]q", vim.cmd.cnext, { desc = "Next quickfix" })

-- Center screen when going to next/previous search result
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

map("n", "sI", vim.show_pos, { desc = "[I]nspect" })

map("n", "<leader>ap", "<cmd>Lazy<CR>", { desc = "[P]lugins" })

map("n", "<leader>al", "<cmd>Mason<CR>", { desc = "[L]anguages" })

map("n", "<leader>aL", function()
    vim.notify("Restarting LSP Servers", vim.log.levels.INFO, { title = "LSP" })
    vim.cmd("LspRestart")
end, { desc = "[R]estart Language Servers" })

map("n", "<leader>aIl", "<cmd>LspInfo<CR>", { desc = "[L]anague Server" })

map("n", "<leader>w.", function()
    local git_root = require("snacks").git.get_root()
    if git_root then
        vim.cmd("cd " .. git_root)
        vim.notify("Changed directory to " .. git_root, vim.log.levels.INFO, { title = "Git Root" })
    else
        vim.notify("No Git root found", vim.log.levels.ERROR, { title = "Git Root" })
    end
end, { desc = "[.] Set Root" })

map("n", "vA", "ggVG", { desc = "Select All" })

map("n", "<leader>dya", function()
    -- Save current cursor position
    local current_pos = vim.fn.getpos(".")

    -- Yank entire buffer
    vim.cmd("norm ggVGy")

    -- Restore cursor position
    vim.fn.setpos(".", current_pos)
end, { desc = "[A]ll" })

map({ "n", "v" }, "<leader>dyp", function()
    lib.copy.list_paths()
end, { desc = "[P]ath" })

vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspConfig", {}),
    callback = function(ev)
        -- Enable completion triggered by <c-x><c-o>
        vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

        local o = function(opts)
            opts = opts or {}
            return vim.tbl_extend("force", opts, { buffer = ev.buf })
        end

        local split_defnition = function()
            vim.cmd.vsplit()
            vim.lsp.buf.definition()
            vim.cmd("norm zz")
        end

        map("n", "si", vim.lsp.buf.hover, { desc = "[I]nfo" })
        map("n", "sp", vim.diagnostic.open_float, { desc = "[P]roblem" })
        map("n", "sa", vim.lsp.buf.code_action, o({ desc = "[A]ction" }))
        map("n", "sn", vim.lsp.buf.rename, o({ desc = "Re[n]ame" }))
        map("n", "sD", split_defnition, o({ desc = "[D]efinition in Split" }))
        map("i", "<C-k>", vim.lsp.buf.signature_help, o({ desc = "Signature Help" }))
    end,
})
