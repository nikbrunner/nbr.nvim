local M = {}

M.toggle_float_files = function()
    vim.cmd("Neotree left close")
    vim.cmd("Neotree float toggle reveal")
end

M.toggle_float_buffers = function()
    vim.cmd("Neotree left close")
    vim.cmd("Neotree float buffers toggle reveal")
end

M.toggle_float_git = function()
    vim.cmd("Neotree right close")
    vim.cmd("Neotree float git_status toggle reveal")
end

M.toggle_left_files = function()
    vim.cmd("UndotreeHide")
    vim.cmd("Neotree float close")
    vim.cmd("Neotree left toggle")
end

M.toggle_undo_tree = function()
    vim.cmd("Neotree left close")
    vim.cmd("UndotreeToggle")
end

M.toggle_symbol_outline = function()
    vim.cmd("Neotree right close")
    vim.cmd("Lspsaga outline")
end

M.toggle_git_status = function()
    -- TODO if there exists a symbol outline close it
    vim.cmd("Neotree right git_status toggle")
end

M.toggle_buffers = function()
    vim.cmd("Neotree left close")
    vim.cmd("Neotree float buffers toggle")
end

return M
