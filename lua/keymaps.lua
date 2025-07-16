local Lib = require("lib")

local M = {}

-- =============================================================================
-- Helper Functions
-- =============================================================================

--- Centralized key mapping function
---@param mode string|table Mode(s) to set the mapping for (e.g., "n", "v", "i", {"n", "v"})
---@param lhs string Left-hand side of the mapping
---@param rhs string|function Right-hand side of the mapping
---@param opts table Optional parameters for vim.keymap.set (e.g., {desc = "Description"})
function M.map(mode, lhs, rhs, opts)
    opts = opts or {}
    opts.noremap = opts.noremap == nil and true or opts.noremap
    opts.silent = opts.silent == nil and true or opts.silent
    vim.keymap.set(mode, lhs, rhs, opts)
end

--- Helper function to open definition in a split (vertical if space allows)
function M.goto_split_definition()
    if vim.o.lines > 100 then
        vim.cmd.split()
    else
        vim.cmd.vsplit()
    end
    vim.lsp.buf.definition()
    vim.cmd("norm zz")
end

function M.set_diagnostic_virtual_text()
    vim.diagnostic.config({
        virtual_lines = false,
        virtual_text = { current_line = false },
    })
end

function M.set_diagnostic_virtual_lines()
    vim.diagnostic.config({
        virtual_lines = { current_line = true },
        virtual_text = false,
    })
end

function M.custom_jump(jumpCount, severity)
    local auto_group_name = "custom_jump"

    pcall(vim.api.nvim_del_augroup_by_name, auto_group_name) -- prevent autocmd for repeated jumps

    vim.diagnostic.jump({
        count = jumpCount,
        severity = severity,
        float = false,
    })

    M.set_diagnostic_virtual_lines()
    vim.cmd("norm zz")
    -- vim.diagnostic.open_float(nil, { focusable = true, source = "if_many" })
    local auto_group = vim.api.nvim_create_augroup(auto_group_name, { clear = true })

    vim.defer_fn(function() -- deferred to not trigger by jump itself
        vim.api.nvim_create_autocmd("CursorMoved", {
            once = true,
            desc = "User(once): Reset diagnostics virtual lines",
            group = auto_group,
            callback = function()
                M.set_diagnostic_virtual_text()
            end,
        })
    end, 1)
end

-- =============================================================================
-- Core Editor Behavior & Navigation
-- =============================================================================

-- Disable Ex mode mapping
M.map("n", "Q", "<nop>", { desc = "Disable Ex Mode" })
-- Disable suspend mapping
-- M.map("n", "s", "<nop>", { desc = "Disable Suspend" })

-- Escape clears search highlight, saves, hides notifier
M.map("n", "<Esc>", function()
    vim.cmd.nohlsearch()
    vim.cmd.wa()
    require("snacks.notifier").hide()
end, { desc = "Escape and clear hlsearch" })

-- Shift+Escape clears notifier and floating windows
M.map("n", "<S-Esc>", function()
    require("snacks.notifier").hide()
    Lib.ui.close_all_floating_windows()
end, { desc = "Clear Notifier and Trouble" })

-- Center screen when moving through jump list
M.map("n", "<C-o>", "<C-o>zz", { desc = "Move back in jump list" })
M.map("n", "<C-i>", "<C-i>zz", { desc = "Move forward in jump list" })

-- Center screen when searching
M.map("n", "N", "Nzzzv", { desc = "Previous Search Results" })
M.map("n", "n", "nzzzv", { desc = "Next Search Results" })

-- Better up/down movement that respects wrapped lines
M.map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
M.map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
M.map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
M.map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Keep cursor position when joining lines
M.map("n", "J", "mzJ`z", { desc = "Join Lines" })

-- Move selected lines up/down in visual mode
M.map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move Selected Lines Up" })
M.map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move Selected Lines Down" })

-- Indenting in visual mode keeps selection
M.map("v", "<", "<gv", { desc = "Indent Selected Lines" })
M.map("v", ">", ">gv", { desc = "Outdent Selected Lines" })

-- Make undo points for common punctuation in insert mode
M.map("i", ",", ",<c-g>u", { desc = "Undo Comma" })
M.map("i", ".", ".<c-g>u", { desc = "Undo Dot" })
M.map("i", ";", ";<c-g>u", { desc = "Undo Semicolon" })

-- Quick access to command mode
M.map({ "n", "x" }, "<leader><leader>", function()
    vim.api.nvim_feedkeys(":", "n", true)
end, { desc = "Command Mode" })

M.map("n", "<leader>aoD", function()
    require("shada").toggle_dev_mode()
end, { desc = "Toggle [D]ev Mode" })

M.map("n", "<leader>ahs", function()
    require("shada").show()
end, { desc = "Show [S]hada" })

-- =============================================================================
-- Editing & Text Manipulation
-- =============================================================================

-- Delete without yanking ("black hole register")
M.map("n", "x", '"_x', { desc = "Delete without yanking" })

-- Duplicate line
M.map("n", "yp", function()
    local col = vim.fn.col(".")
    vim.cmd("norm yy")
    vim.cmd("norm p")
    vim.fn.cursor(vim.fn.line("."), col)
end, { desc = "Duplicate line" })

-- Duplicate line and comment out the original
M.map("n", "yc", function()
    local col = vim.fn.col(".")
    vim.cmd("norm yy")
    vim.cmd("norm gcc")
    vim.cmd("norm p")
    vim.fn.cursor(vim.fn.line("."), col)
end, { desc = "Dupe line (Comment out old one)" })

-- Select All
M.map("n", "vA", "ggVG", { desc = "Select All" })

-- Change inside word (convenience)
M.map("n", "<space>", "ciw", { desc = "Change Inside Word" })
M.map("x", "<space>", "c", { desc = "Change Selection" })

-- Yank entire buffer content
M.map("n", "<leader>dya", function()
    -- Save current cursor position
    local current_pos = vim.fn.getpos(".")
    -- Yank entire buffer
    vim.cmd("norm ggVGy")
    -- Restore cursor position
    vim.fn.setpos(".", current_pos)
end, { desc = "[A]ll" })

-- Yank current file path(s) (uses lib function)
M.map({ "n", "v" }, "<leader>dyp", function()
    Lib.copy.list_paths()
end, { desc = "[P]ath" })

-- =============================================================================
-- Window, Tab, and Split Management
-- =============================================================================

-- Navigate tabs
M.map("n", "H", vim.cmd.tabprevious, { desc = "Previous Tab" })
M.map("n", "L", vim.cmd.tabnext, { desc = "Next Tab" })

-- Go to tab number (creates new tab if needed)
for i = 1, 9 do
    M.map("n", "<leader>" .. i, function()
        local existing_tab_count = vim.fn.tabpagenr("$")

        if existing_tab_count < i then
            vim.cmd("tablast")
            vim.cmd("tabnew")
        else
            vim.cmd(i .. "tabnext")
        end
    end, { desc = WhichKeyIgnoreLabel }) -- Assuming WhichKeyIgnoreLabel is defined elsewhere
end

-- Resize splits using Shift + Arrow keys
M.map({ "n", "v", "x" }, "<S-Down>", "<cmd>resize -2<cr>", { desc = "Resize Split Down" })
M.map({ "n", "v", "x" }, "<S-Up>", "<cmd>resize +2<cr>", { desc = "Resize Split Up" })
M.map({ "n", "v", "x" }, "<S-Left>", "<cmd>vertical resize +5<cr>", { desc = "Resize Split Right" }) -- Note: Left arrow increases width to the right
M.map({ "n", "v", "x" }, "<S-Right>", "<cmd>vertical resize -5<cr>", { desc = "Resize Split Left" }) -- Note: Right arrow decreases width from the right

-- =============================================================================
-- File & Session Management
-- =============================================================================

-- Save and Quit
M.map("n", "<C-s>", vim.cmd.wa, { desc = "Save" })
M.map("n", "<C-q>", ":q!<CR>", { desc = "Quit" }) -- Force quit

-- Open last edited file
M.map("n", "<leader>dl", "<cmd>e #<cr>", { desc = "[L]ast document" })

-- =============================================================================
-- Terminal Mode
-- =============================================================================

M.map("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit Terminal" })

-- =============================================================================
-- Plugin & Tool Integrations
-- =============================================================================

-- Open current file in Zed editor at the current cursor position
M.map("n", "<leader>z", function()
    local current_file = vim.fn.expand("%:p")
    local current_line = vim.fn.line(".")
    local current_column = vim.fn.col(".")

    vim.cmd("silent !zed " .. current_file .. ":" .. current_line .. ":" .. current_column)
end, { desc = "Open File in [Z]ed" })

-- Plugin management (Lazy)
M.map("n", "<leader>ap", "<cmd>Lazy<CR>", { desc = "[P]lugins" })

-- Change directory to Git root
M.map("n", "<leader>w.", function()
    local git_root = require("snacks").git.get_root() -- Assumes 'snacks' plugin/module
    if git_root then
        vim.cmd("cd " .. git_root)
        vim.notify("Changed directory to " .. git_root, vim.log.levels.INFO, { title = "Git Root" })
    else
        vim.notify("No Git root found", vim.log.levels.ERROR, { title = "Git Root" })
    end
end, { desc = "[.] Set Root" })

-- =============================================================================
-- LSP (Language Server Protocol) Related Mappings & Language Management
-- =============================================================================
M.map("n", "<leader>als", "<cmd>Mason<CR>", { desc = "[S]ervers" })
M.map("n", "<leader>alr", "<cmd>LspRestart<CR>", { desc = "[R]estart" })
M.map("n", "<leader>ali", "<cmd>LspInfo<CR>", { desc = "[I]nfo" })
M.map("n", "<leader>all", "<cmd>LspLog<CR>", { desc = "[L]og" })

-- Show cursor position and related info

M.map("n", "sI", vim.show_pos, { desc = "[I]nspect Position" })

-- LSP mappings are defined below within the LspAttach autocmd for buffer-local setup

-- =============================================================================
-- Autocommands
-- =============================================================================

vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspConfig", {}),
    callback = function(ev)
        -- Enable completion triggered by <c-x><c-o>
        vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

        -- Helper to add buffer scope to opts
        local function o(opts)
            opts = opts or {}
            return vim.tbl_extend("force", opts, { buffer = ev.buf })
        end

        -- LSP Hover Info
        M.map("n", "si", vim.lsp.buf.hover, o({ desc = "[I]nfo" }))

        -- LSP Diagnostics
        -- M.map("n", "sp", vim.diagnostic.open_float, o({ desc = "[P]roblems (Float)" }))
        M.map("n", "sp", function()
            M.set_diagnostic_virtual_lines()

            vim.api.nvim_create_autocmd("CursorMoved", {
                group = vim.api.nvim_create_augroup("symbol-problems", {}),
                desc = "User(once): Reset diagnostics virtual lines",
                once = true,
                callback = function()
                    M.set_diagnostic_virtual_text()
                    return true
                end,
            })
        end, o({ desc = "[P]roblems (Inline)" }))

        -- vim.api.nvim_create_autocmd("CursorHold", {
        --     group = vim.api.nvim_create_augroup("cursor-hold-diagnostics", {}),
        --     desc = "User: On cursor hold, reset diagnostics virtual lines",
        --     callback = function()
        --         -- vim.diagnostic.open_float(nil, { focusable = true, source = "if_many" })
        --         M.set_diagnostic_virtual_lines()
        --     end,
        -- })
        --
        -- Helper function to create diagnostic navigation mappings
        local function create_diagnostic_mappings(key, severity_type, severity_value)
            local severity_param = severity_value and { severity = severity_value } or nil

            -- Previous diagnostic
            M.map("n", "[" .. key, function()
                M.custom_jump(-1, severity_param)
            end, o({ desc = "[" .. severity_type .. "] Previous" }))

            -- Next diagnostic
            M.map("n", "]" .. key, function()
                M.custom_jump(1, severity_param)
            end, o({ desc = "[" .. severity_type .. "] Next" }))
        end

        -- Create mappings for diagnostic navigation (all, error, warning, hint)
        create_diagnostic_mappings("d", "[D]iagnostic", nil)
        create_diagnostic_mappings("e", "[E]rror", vim.diagnostic.severity.ERROR)
        create_diagnostic_mappings("w", "[W]arning", vim.diagnostic.severity.WARN)
        create_diagnostic_mappings("h", "[H]int", vim.diagnostic.severity.HINT)

        -- LSP Actions & Refactoring
        M.map("n", "sa", vim.lsp.buf.code_action, o({ desc = "[A]ction" })) -- Original was commented out
        M.map("n", "sn", vim.lsp.buf.rename, o({ desc = "Re[n]ame" }))

        -- LSP Go To Definition (in split)
        M.map("n", "sD", M.goto_split_definition, o({ desc = "[D]efinition in Split" })) -- Uses helper defined above

        -- LSP Signature Help (Insert mode)
        M.map("i", "<C-k>", vim.lsp.buf.signature_help, o({ desc = "Signature Help" }))
    end,
})
