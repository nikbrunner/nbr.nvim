local M = {}

---@class State
---@field is_deno_project boolean
M.state = {
    is_deno_project = false,
}

---@alias StateKey "is_deno_project"

-- Getter and setter functions
---@param key StateKey
function M:get(key)
    return self.state[key]
end

---@param key StateKey
---@param value any
function M:set(key, value)
    self.state[key] = value
    return self.state[key]
end

-- Toggle function
---@param key StateKey
function M:toggle(key)
    self.state[key] = not self.state[key]
    return self.state[key]
end

return M
