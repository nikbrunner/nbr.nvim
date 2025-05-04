local M = {}

---If the dev mode is enabled, then return the dev path, otherwise return nil
---This will cause lazy to use the git repo instead of the dev path
---@param project_path string The path starting from my repos folder
---@return string|nil
---
--- Example:
---
--- ```lua
---{
---    "black-atom-industries/nvim",
---    name = "black-atom",
---    dir = Lib.config.get_plugin_dir("black-atom-industries/nvim"),
---    lazy = false,
---    priority = 1000,
--- }
--- ```
function M.get_repo_path(project_path)
    local Config = require("config")
    local ShaDa = require("shada")

    if ShaDa.read().dev_mode then
        return Config.pathes.repos .. "/" .. project_path
    else
        return nil
    end
end

return M
