local map = vim.keymap.set
local user_command = vim.api.nvim_create_user_command

vim.opt_local.wrap = true
vim.opt_local.conceallevel = 0

local function toggle_checkbox(opts)
    local checked_pattern = "%- %[x%]"
    local unchecked_pattern = "%- %[ %]"

    local function process_line(line)
        if line:match(checked_pattern) then
            return line:gsub(checked_pattern, "- [ ]")
        elseif line:match(unchecked_pattern) then
            return line:gsub(unchecked_pattern, "- [x]")
        elseif line:match("^%s*$") then
            return "- [ ] "
        end
        return line
    end

    -- Check if we have a range
    if opts.range > 0 then
        local start_line = opts.line1
        local end_line = opts.line2

        -- Get all the lines in the selection
        local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

        -- Process each line
        for i, line in ipairs(lines) do
            lines[i] = process_line(line)
        end

        -- Set the modified lines
        vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, lines)
    else
        -- Single-line behavior
        local line = vim.api.nvim_get_current_line()
        local move_cursor_to_end = line:match("^%s*$") ~= nil

        line = process_line(line)

        -- Set the modified line
        local row = vim.api.nvim_win_get_cursor(0)[1]
        vim.api.nvim_buf_set_lines(0, row - 1, row, false, { line })

        -- Move cursor to end of line if needed
        if move_cursor_to_end then
            local line_length = #line
            vim.api.nvim_win_set_cursor(0, { row, line_length })
        end
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

-- Function to create a code block and position cursor for language input
local function create_code_block()
    -- Get current cursor position and mode
    local row = vim.api.nvim_win_get_cursor(0)[1]
    local mode = vim.api.nvim_get_mode().mode

    -- Insert the code block
    vim.api.nvim_buf_set_lines(0, row - 1, row, false, {
        "```",
        "```",
    })

    -- Move cursor to the end of the first line
    vim.api.nvim_win_set_cursor(0, { row, 3 })

    if mode == "n" then
        vim.cmd("startinsert!") -- equivalent to 'a'
    else
        vim.cmd("startinsert") -- equivalent to 'i'
    end
end

user_command("ToggleCheckbox", toggle_checkbox, { range = true })

map({ "n", "o", "x" }, "j", "gj", {})
map({ "n", "o", "x" }, "k", "gk", {})
map({ "n", "o", "x" }, "0", "g0", {})
map({ "n", "o", "x" }, "$", "g$", {})
map({ "n", "v" }, "<C-t>", ":ToggleCheckbox<CR>", { noremap = true, silent = true, buffer = true })
map({ "n", "i" }, "<C-b>", create_code_block, { noremap = true, silent = true, buffer = true })
map({ "i" }, "<CR>", continue_list, { buffer = true, expr = false })
