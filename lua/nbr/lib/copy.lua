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

-- TODO: Reimplement logic to list github link in here
function M.get_github_url()
    -- local current_vim_mode = vim.api.nvim_get_mode().mode
    -- local mode_for_plugin = current_vim_mode == "n" and "n" or "v"
    --
    -- return require("gitlinker").get_buf_range_url(mode_for_plugin, { print_url = false })
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

M.list_paths = function()
    local fzf = require("fzf-lua")
    -- local github_url = M.get_github_url()

    function M.file_paths()
        local paths = {
            { type = "Filename", name = M.file_name() },
            { type = "Relative /w Line Number", name = M.get_current_relative_path(true) },
            { type = "Relative", name = M.get_current_relative_path(false) },
            { type = "Full Path (Home)", name = M.full_path_from_home() },
            { type = "Full Path (Absolute)", name = M.full_path() },
            -- github_url and { type = "GitHub", name = github_url } or nil,
        }
        return vim.tbl_filter(function(path)
            return path
        end, paths)
    end

    local results = M.file_paths()

    local entries = {}
    local max_length = 0
    for _, path in ipairs(results) do
        local entry = path.type .. ": " .. path.name
        table.insert(entries, entry)
        if #entry > max_length then
            max_length = #entry
        end
    end

    local win_width = math.min(0.9, (max_length / vim.o.columns) + 0.1)

    fzf.fzf_exec(entries, {
        prompt = "Yank Document Meta> ",
        previewer = false,
        winopts = {
            row = 0.85,
            col = 0.5,
            height = 0.35,
            -- width = win_width,
            preview = { hidden = "hidden" },
        },
        actions = {
            ["default"] = function(selected)
                local _, path_name = selected[1]:match("^(.-): (.*)$")
                copy(path_name)
                vim.notify('Copied "' .. path_name .. '" to the clipboard!', vim.log.levels.INFO)
            end,
            ["ctrl-p"] = function(selected)
                local _, path_name = selected[1]:match("^(.-): (.*)$")
                vim.api.nvim_paste(path_name, true, -1)
            end,
            ["P"] = function(selected)
                local _, path_name = selected[1]:match("^(.-): (.*)$")
                vim.api.nvim_put({ path_name }, "l", false, false)
            end,
            ["p"] = function(selected)
                local _, path_name = selected[1]:match("^(.-): (.*)$")
                vim.api.nvim_put({ path_name }, "l", true, false)
            end,
            ["alt-enter"] = function(selected)
                local path_type, path_name = selected[1]:match("^(.-): (.*)$")
                if path_type == "GitHub" then
                    require("gitlinker.actions").open_in_browser(path_name)
                    vim.notify("Opening GitHub Link in Browser", vim.log.levels.INFO)
                else
                    vim.notify("No action for this path type" .. path_type, vim.log.levels.WARN)
                end
            end,
        },
    })
end

return M
