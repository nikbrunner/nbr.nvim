local map = vim.keymap.set

local function toggle_checkbox()
    local line = vim.api.nvim_get_current_line()

    local checked_pattern = "%- %[x%]"
    local unchecked_pattern = "%- %[ %]"
    local move_cursor_to_end = false

    if line:match(checked_pattern) then
        line = line:gsub(checked_pattern, "- [ ]")
    elseif line:match(unchecked_pattern) then
        line = line:gsub(unchecked_pattern, "- [x]")
    elseif line:match("^%s*$") then
        line = "- [ ] "
        move_cursor_to_end = true
    end

    -- Set the modified line
    local row = vim.api.nvim_win_get_cursor(0)[1]
    vim.api.nvim_buf_set_lines(0, row - 1, row, false, { line })

    -- Move cursor to end of line if needed
    if move_cursor_to_end then
        local line_length = #line
        vim.api.nvim_win_set_cursor(0, { row, line_length })
    end
end

map({ "n", "o", "x" }, "j", "gj", {})
map({ "n", "o", "x" }, "k", "gk", {})
map({ "n", "o", "x" }, "0", "g0", {})
map({ "n", "o", "x" }, "$", "g$", {})
map({ "n", "i" }, "<C-CR>", toggle_checkbox, { noremap = true, silent = true })

vim.opt.wrap = true
