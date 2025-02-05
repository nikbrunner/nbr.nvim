local M = {}

local function copy(path)
    vim.fn.setreg("+", path)
    vim.notify('Copied "' .. path .. '" to the clipboard!', vim.log.levels.INFO)
end

function M.full_path()
    return vim.fn.expand("%:p")
end

function M.full_path_from_home()
    return vim.fn.expand("%:~")
end

function M.file_name()
    return vim.fn.expand("%:t")
end

function M.get_current_relative_path(with_line_number)
    local current_file = vim.fn.expand("%")
    local current_line = vim.fn.line(".")
    local relative_path = vim.fn.fnamemodify(current_file, ":~:.")

    if with_line_number then
        return relative_path .. "#L" .. current_line
    end

    return relative_path
end

function M.gen_items(tbl)
    local items = {}
    for key, value in pairs(tbl) do
        table.insert(items, { text = key, preview = { text = value } })
    end
    return items
end

M.list_paths = function()
    ---@type snacks.picker.finder.Item[]
    local pathes = {
        { text = "1. Filename", idx = 1, preview = { text = M.file_name() } },
        { text = "2. Relative", idx = 2, preview = { text = M.get_current_relative_path(false) } },
        { text = "3. Relative /w Line Number", idx = 3, preview = { text = M.get_current_relative_path(true) } },
        { text = "4. Full Path (Home)", idx = 4, preview = { text = M.full_path_from_home() } },
        { text = "5. Full Path (Absolute)", idx = 5, preview = { text = M.full_path() } },
    }

    local max_length = M.full_path():len()
    local win_width = math.min(0.9, (max_length / vim.o.columns) + 0.1)

    Snacks.picker.pick({
        source = "Copy File Meta",
        items = pathes,
        preview = "preview",
        format = "text",
        layout = {
            layout = {
                box = "horizontal",
                row = 0.65,
                width = win_width,
                min_width = max_length + 2,
                height = 13,
                {
                    box = "vertical",
                    border = "solid",
                    title = "{title} {live} {flags}",
                    { win = "preview", title = "{preview}", border = "vpad", height = 1 },
                    { win = "input", height = 1, border = "bottom" },
                    { win = "list", border = "none" },
                },
            },
        },
        confirm = function(picker, item)
            copy(item.preview.text)
            vim.notify_once("Copied '" .. item.preview.text .. "' to the clipboard!", vim.log.levels.INFO)
            picker:close()
        end,
        on_close = function()
            vim.notify("Cool that you build this little picker! 😎", vim.log.levels.INFO)
        end,
    })
end

return M
