local Config = require("config")

-- This module is used to read and write certain application state properties,
-- that should not be tracked by git. (See `:h shada`)
---@class Vin.Shada
local M = {}

---@alias Vin.Shada.Key "dev_mode"|"background"|"colorscheme_light"|"colorscheme_dark"

---@class Vin.State
---@field dev_mode boolean Whether dev mode is enabled
---@field background string Background mode ('light' or 'dark')
---@field colorscheme_light string Name of the light colorscheme
---@field colorscheme_dark string Name of the dark colorscheme

---Path to the state file
---@type string
M.file = vim.fn.stdpath("state") .. "/nbr/state.json"

---Default state values from config
---@type Vin.State
M.default_state = {
    dev_mode = Config.dev_mode,
    background = Config.background,
    colorscheme_light = Config.colorscheme_light,
    colorscheme_dark = Config.colorscheme_dark,
}

---Read the persisted state file
---@overload fun(): Vin.State
---@overload fun(key: "dev_mode"): boolean
---@overload fun(key: "background"|"colorscheme_light"|"colorscheme_dark"): string
function M.read(key)
    local state = {}

    -- Return default state if file doesn't exist
    if not vim.loop.fs_stat(M.file) then
        vim.notify_once(
            "State file doesn't exist yet. Using default config values and will create file at: '" .. M.file .. "'",
            vim.log.levels.INFO
        )
        state = M.default_state
    else
        local ok, content = pcall(vim.fn.readfile, M.file)
        if not ok or not content or #content == 0 then
            vim.notify_once("Failed to read state file. Using default config values.", vim.log.levels.WARN)
            state = M.default_state
        else
            -- Parse JSON content
            local ok2, decoded_state = pcall(vim.json.decode, table.concat(content, "\n"))
            if not ok2 or not decoded_state then
                vim.notify_once("Failed to parse state file. Using default config values.", vim.log.levels.WARN)
                state = M.default_state
            else
                state = decoded_state
            end
        end
    end

    -- If a key is provided, return the specific value
    if key then
        return state[key]
    end

    -- Otherwise return the entire state
    return state
end

---Write to the persisted state file
---@param state Vin.State The state to write
---@return boolean success Whether the operation was scheduled successfully
function M.write(state)
    if not state or type(state) ~= "table" then
        vim.notify("Invalid state data", vim.log.levels.ERROR)
        return false
    end

    -- Convert state to JSON
    local ok, json = pcall(vim.json.encode, state)
    if not ok or not json then
        vim.notify_once("Failed to encode state to JSON", vim.log.levels.ERROR)
        return false
    end

    -- Write to file with delay to avoid potential file corruption
    vim.defer_fn(function()
        local write_ok, err = pcall(function()
            vim.fn.mkdir(vim.fn.fnamemodify(M.file, ":h"), "p")
            vim.fn.writefile({ json }, M.file)
        end)

        if not write_ok then
            vim.notify_once("Failed to write state file: " .. (err or "unknown error"), vim.log.levels.ERROR)
        end
    end, 500)

    return true
end

---Updates a specific state key with value
---@overload fun(key: "dev_mode", value: boolean): Vin.State
---@overload fun(key: "background"|"colorscheme_light"|"colorscheme_dark", value: string): Vin.State
function M.update(key, value)
    -- Use explicit typing here to help the type checker
    ---@type Vin.State
    local state = M.read()
    state[key] = value
    M.write(state)
    return state
end

---Toggle a boolean state value
---@param key "dev_mode" The state key to toggle (must be a boolean value)
---@return boolean value The new value after toggling
function M.toggle(key)
    ---@type Vin.State
    local state = M.read()
    --- Check if the value of the key is a boolean
    if type(state[key]) ~= "boolean" then
        vim.notify_once("Key is not associated with a boolean value", vim.log.levels.WARN)
        return state[key]
    end
    state[key] = not state[key]
    M.write(state)
    return state[key]
end

---Toggle the dev_mode setting and show a notification
---@return boolean is_enabled Whether dev mode is now enabled
function M.toggle_dev_mode()
    local is_enabled = M.toggle("dev_mode")

    vim.notify(
        "Dev Mode: "
            .. (is_enabled and "ON" or "OFF")
            .. "\n"
            .. "Please restart Neovim for changes to take effect."
            .. "\n"
            .. "After that, plugins will use their project path if defined.",
        vim.log.levels.INFO,
        { title = "Vin" }
    )

    return is_enabled
end

function M.show()
    local state = M.read()

    -- Open floating window and put the state in it
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(
        buf,
        0,
        -1,
        false,
        vim.tbl_map(function(k)
            return k .. ": " .. tostring(state[k])
        end, vim.tbl_keys(state))
    )

    -- Open floating window
    vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = math.floor(vim.o.columns * 0.25),
        height = math.floor(vim.o.lines * 0.25),
        row = math.floor(vim.o.lines * 0.25),
        col = math.floor(vim.o.columns * 0.5),
        style = "minimal",
        border = "solid",
        title = "Vin Shada",
    })

    -- Map <Esc> to close the window
    vim.api.nvim_buf_set_keymap(buf, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
end

return M
