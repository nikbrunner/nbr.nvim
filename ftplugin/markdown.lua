local map = vim.keymap.set

vim.opt_local.wrap = true

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

local function continue_list()
    local line = vim.api.nvim_get_current_line()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local row = cursor[1]

    -- Check for checkbox pattern first
    local checkbox_pattern = "^%s*-%s%[.%]%s"
    if line:match(checkbox_pattern) then
        -- Get the indentation
        local indent = line:match("^(%s*)")

        -- If the current line is empty except for the checkbox, remove it
        if line:match("^%s*-%s%[.%]%s*$") then
            vim.api.nvim_buf_set_lines(0, row - 1, row, false, { "" })
            return vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), "n", true)
        end

        -- Create a new unchecked checkbox
        return vim.api.nvim_feedkeys(
            vim.api.nvim_replace_termcodes("<CR>" .. indent .. "- [ ] ", true, false, true),
            "n",
            true
        )
    end

    -- Check for regular list items (- or *)
    local list_pattern = "^%s*[-*]%s"
    if line:match(list_pattern) then
        -- Get the list marker and its indentation
        local indent = line:match("^(%s*)")
        local marker = line:match("^%s*([-*])")

        -- If the current line is empty except for the marker, remove it
        if line:match("^%s*[-*]%s*$") then
            vim.api.nvim_buf_set_lines(0, row - 1, row, false, { "" })
            return vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), "n", true)
        end

        -- Create a new list item
        return vim.api.nvim_feedkeys(
            vim.api.nvim_replace_termcodes("<CR>" .. indent .. marker .. " ", true, false, true),
            "n",
            true
        )
    end

    -- If not on a list item or checkbox, just return a normal Enter
    return vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), "n", true)
end

map({ "n", "o", "x" }, "j", "gj", {})
map({ "n", "o", "x" }, "k", "gk", {})
map({ "n", "o", "x" }, "0", "g0", {})
map({ "n", "o", "x" }, "$", "g$", {})
map({ "n", "i" }, "<C-CR>", toggle_checkbox, { noremap = true, silent = true })
map({ "i" }, "<CR>", continue_list, { buffer = true, expr = false })
