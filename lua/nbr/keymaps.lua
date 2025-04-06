---@diagnostic disable: undefined-field
local lib = require("nbr.lib")

-- =============================================================================
-- Helper Functions
-- =============================================================================

--- Centralized key mapping function
---@param mode string|table Mode(s) to set the mapping for (e.g., "n", "v", "i", {"n", "v"})
---@param lhs string Left-hand side of the mapping
---@param rhs string|function Right-hand side of the mapping
---@param opts table Optional parameters for vim.keymap.set (e.g., {desc = "Description"})
local function map(mode, lhs, rhs, opts)
    opts = opts or {}
    opts.noremap = opts.noremap == nil and true or opts.noremap
    opts.silent = opts.silent == nil and true or opts.silent
    vim.keymap.set(mode, lhs, rhs, opts)
end

--- Helper function for smarter scrolling with <C-u>
local function special_up()
    local cursorline = vim.fn.line(".")
    local first_visible = vim.fn.line("w0")
    local travel = math.floor(vim.api.nvim_win_get_height(0) / 2)

    if (cursorline - travel) < first_visible then
        vim.cmd('execute "normal! ' .. travel .. '\\<C-y>"')
    else
        vim.cmd('execute "normal! ' .. travel .. '\\k"')
        vim.cmd("normal! zz")
    end
end

--- Helper function for smarter scrolling with <C-d>
local function special_down()
    local cursorline = vim.fn.line(".")
    local last_visible = vim.fn.line("w$")
    local travel = math.floor(vim.api.nvim_win_get_height(0) / 2)

    if (cursorline + travel) > last_visible and last_visible < vim.fn.line("$") then
        vim.cmd('execute "normal! ' .. travel .. '\\<C-e>"')
    elseif cursorline < last_visible then
        vim.cmd('execute "normal! ' .. travel .. '\\j"')
        vim.cmd("normal! zz")
    end
end

--- Helper function to open definition in a split (vertical if space allows)
local function split_defnition()
    if vim.o.lines > 100 then
        vim.cmd.split()
    else
        vim.cmd.vsplit()
    end
    vim.lsp.buf.definition()
    vim.cmd("norm zz")
end

-- =============================================================================
-- Core Editor Behavior & Navigation
-- =============================================================================

-- Disable Ex mode mapping
map("n", "Q", "<nop>", { desc = "Disable Ex Mode" })
-- Disable suspend mapping
map("n", "s", "<Nop>", { desc = "Disable Suspend" })

-- Escape clears search highlight, saves, hides notifier
map("n", "<Esc>", function()
    vim.cmd.nohlsearch()
    vim.cmd.wa()
    require("snacks.notifier").hide()
end, { desc = "Escape and clear hlsearch" })

-- Shift+Escape clears notifier and floating windows
map("n", "<S-Esc>", function()
    require("snacks.notifier").hide()
    lib.ui.close_all_floating_windows()
end, { desc = "Clear Notifier and Trouble" })

-- Center screen when moving through jump list
map("n", "<C-o>", "<C-o>zz", { desc = "Move back in jump list" })
map("n", "<C-i>", "<C-i>zz", { desc = "Move forward in jump list" })

-- Center screen when searching
map("n", "N", "Nzzzv", { desc = "Previous Search Results" })
map("n", "n", "nzzzv", { desc = "Next Search Results" })

-- Smarter scrolling keeping cursor centered, while other looking up and down conditionally
map({ "n", "x" }, "<C-u>", special_up, { desc = "Scroll Up (Centered)" })
map({ "n", "x" }, "<C-d>", special_down, { desc = "Scroll Down (Centered)" })

-- Better up/down movement that respects wrapped lines
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Keep cursor position when joining lines
map("n", "J", "mzJ`z", { desc = "Join Lines" })

-- Move selected lines up/down in visual mode
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move Selected Lines Up" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move Selected Lines Down" })

-- Indenting in visual mode keeps selection
map("v", "<", "<gv", { desc = "Indent Selected Lines" })
map("v", ">", ">gv", { desc = "Outdent Selected Lines" })

-- Make undo points for common punctuation in insert mode
map("i", ",", ",<c-g>u", { desc = "Undo Comma" })
map("i", ".", ".<c-g>u", { desc = "Undo Dot" })
map("i", ";", ";<c-g>u", { desc = "Undo Semicolon" })

-- Quick access to command mode
map({ "n", "x" }, "<leader><leader>", function()
    vim.api.nvim_feedkeys(":", "n", true)
end, { desc = "Command Mode" })

-- =============================================================================
-- Editing & Text Manipulation
-- =============================================================================

-- Delete without yanking ("black hole register")
map("n", "x", '"_x', { desc = "Delete without yanking" })

-- Duplicate line
map("n", "yp", function()
    local col = vim.fn.col(".")
    vim.cmd("norm yy")
    vim.cmd("norm p")
    vim.fn.cursor(vim.fn.line("."), col)
end, { desc = "Duplicate line" })

-- Duplicate line and comment out the original
map("n", "yc", function()
    local col = vim.fn.col(".")
    vim.cmd("norm yy")
    vim.cmd("norm gcc")
    vim.cmd("norm p")
    vim.fn.cursor(vim.fn.line("."), col)
end, { desc = "Dupe line (Comment out old one)" })

-- Select All
map("n", "vA", "ggVG", { desc = "Select All" })

-- Change inside word (convenience)
-- map("n", "<C-c>", "ciw", { desc = "Change Inside Word" })
map("n", "<space>", "ciw", { desc = "Change Inside Word" })
map("x", "<space>", "c", { desc = "Change Selection" })

-- Yank entire buffer content
map("n", "<leader>dya", function()
    -- Save current cursor position
    local current_pos = vim.fn.getpos(".")
    -- Yank entire buffer
    vim.cmd("norm ggVGy")
    -- Restore cursor position
    vim.fn.setpos(".", current_pos)
end, { desc = "[A]ll" })

-- Yank current file path(s) (uses lib function)
map({ "n", "v" }, "<leader>dyp", function()
    lib.copy.list_paths()
end, { desc = "[P]ath" })

-- =============================================================================
-- Window, Tab, and Split Management
-- =============================================================================

-- Navigate tabs
map("n", "H", vim.cmd.tabprevious, { desc = "Previous Tab" })
map("n", "L", vim.cmd.tabnext, { desc = "Next Tab" })

-- Go to tab number (creates new tab if needed)
for i = 1, 9 do
    map("n", "<leader>" .. i, function()
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
map({ "n", "v", "x" }, "<S-Down>", "<cmd>resize -2<cr>", { desc = "Resize Split Down" })
map({ "n", "v", "x" }, "<S-Up>", "<cmd>resize +2<cr>", { desc = "Resize Split Up" })
map({ "n", "v", "x" }, "<S-Left>", "<cmd>vertical resize +5<cr>", { desc = "Resize Split Right" }) -- Note: Left arrow increases width to the right
map({ "n", "v", "x" }, "<S-Right>", "<cmd>vertical resize -5<cr>", { desc = "Resize Split Left" }) -- Note: Right arrow decreases width from the right

-- =============================================================================
-- File & Session Management
-- =============================================================================

-- Save and Quit
map("n", "<C-s>", vim.cmd.wa, { desc = "Save" })
map("n", "<C-q>", ":q!<CR>", { desc = "Quit" }) -- Force quit

-- Open last edited file
map("n", "<leader>dl", "<cmd>e #<cr>", { desc = "[L]ast document" })

-- =============================================================================
-- Terminal Mode
-- =============================================================================

map("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit Terminal" })

-- =============================================================================
-- Plugin & Tool Integrations
-- =============================================================================

-- Open current file in Zed editor at the current cursor position
map("n", "<leader>z", function()
    local current_file = vim.fn.expand("%:p")
    local current_line = vim.fn.line(".")
    local current_column = vim.fn.col(".")

    vim.cmd("silent !zed " .. current_file .. ":" .. current_line .. ":" .. current_column)
end, { desc = "Open File in [Z]ed" })

-- Plugin management (Lazy)
map("n", "<leader>ap", "<cmd>Lazy<CR>", { desc = "[P]lugins" })

-- Language server / tool management (Mason)
map("n", "<leader>al", "<cmd>Mason<CR>", { desc = "[L]anguages" })

-- Change directory to Git root
map("n", "<leader>w.", function()
    local git_root = require("snacks").git.get_root() -- Assumes 'snacks' plugin/module
    if git_root then
        vim.cmd("cd " .. git_root)
        vim.notify("Changed directory to " .. git_root, vim.log.levels.INFO, { title = "Git Root" })
    else
        vim.notify("No Git root found", vim.log.levels.ERROR, { title = "Git Root" })
    end
end, { desc = "[.] Set Root" })

-- =============================================================================
-- LSP (Language Server Protocol) Related Mappings
-- =============================================================================

-- Show cursor position and related info
map("n", "sI", vim.show_pos, { desc = "[I]nspect Position" })

-- LSP Management
map("n", "<leader>aL", function()
    vim.notify("Restarting LSP Servers", vim.log.levels.INFO, { title = "LSP" })
    vim.cmd("LspRestart")
end, { desc = "[R]estart Language Servers" })

map("n", "<leader>aIl", "<cmd>LspInfo<CR>", { desc = "[I]nfo Language Server" })

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
        map("n", "si", vim.lsp.buf.hover, o({ desc = "[I]nfo" }))

        -- LSP Diagnostics
        -- map("n", "sp", vim.diagnostic.open_float, o({ desc = "[P]roblem (Diagnostics)" }))
        vim.keymap.set("n", "sp", function()
            vim.diagnostic.config({ virtual_lines = { current_line = true }, virtual_text = false })

            vim.api.nvim_create_autocmd("CursorMoved", {
                group = vim.api.nvim_create_augroup("line-diagnostics", { clear = true }),
                callback = function()
                    vim.diagnostic.config({
                        virtual_lines = false,
                        virtual_text = {
                            current_line = true,
                        },
                    })
                    return true
                end,
            })
        end)

        -- Helper function to create diagnostic navigation mappings
        local function create_diagnostic_mappings(key, severity_type, severity_value)
            local severity_param = severity_value and { severity = severity_value } or nil

            -- Previous diagnostic
            map("n", "[" .. key, function()
                -- Use vim.diagnostic.jump for consistent behavior (includes centering)
                vim.diagnostic.jump({ count = -1, float = false, severity = severity_param }) -- -1 for previous
                vim.cmd("norm zz")
            end, o({ desc = "[" .. severity_type .. "] Previous" }))

            -- Next diagnostic
            map("n", "]" .. key, function()
                -- Use vim.diagnostic.jump for consistent behavior (includes centering)
                vim.diagnostic.jump({ count = 1, float = false, severity = severity_param }) -- 1 for next
                vim.cmd("norm zz")
            end, o({ desc = "[" .. severity_type .. "] Next" }))
        end

        -- Create mappings for diagnostic navigation (all, error, warning, hint)
        create_diagnostic_mappings("d", "[D]iagnostic", nil)
        create_diagnostic_mappings("e", "[E]rror", vim.diagnostic.severity.ERROR)
        create_diagnostic_mappings("w", "[W]arning", vim.diagnostic.severity.WARN)
        create_diagnostic_mappings("h", "[H]int", vim.diagnostic.severity.HINT)

        -- LSP Actions & Refactoring
        -- map("n", "sa", vim.lsp.buf.code_action, o({ desc = "[A]ction" })) -- Original was commented out
        map("n", "sn", vim.lsp.buf.rename, o({ desc = "Re[n]ame" }))

        -- LSP Go To Definition (in split)
        map("n", "sD", split_defnition, o({ desc = "[D]efinition in Split" })) -- Uses helper defined above

        -- LSP Signature Help (Insert mode)
        map("i", "<C-k>", vim.lsp.buf.signature_help, o({ desc = "Signature Help" }))
    end,
})
