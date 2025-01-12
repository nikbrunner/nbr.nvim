local M = {}

---comment
---@return string | nil
function M.get_current_git_branch()
    -- Command to get the current Git branch name
    local cmd = "git rev-parse --abbrev-ref HEAD"

    -- Open the command for reading
    local handle = io.popen(cmd)
    if not handle then
        vim.notify("Failed to execute git command", vim.log.levels.ERROR)
        return nil
    end

    -- Read the command's output (the current branch name)
    local branch_name = handle:read("*a")
    handle:close()

    -- Trim any trailing whitespace from the branch name
    branch_name = string.match(branch_name, "^%s*(.-)%s*$")

    if branch_name == "" then
        vim.notify("Git branch not found or Git not initialized", vim.log.levels.ERROR)
        return nil
    end

    return branch_name
end

---Parses from the provided branch name a issue number and returns it either capitalized or `nil`, if non is found.
---@param branch_name string
---@return string | nil
---Examples:
---```lua
---parse_issue_id_from_branch("feature/dev-123-some-new-feature") -> "DEV-123"
---parse_issue_id_from_branch("dev") -> nil
---```
function M.parse_issue_id_from_branch(branch_name)
    -- Pattern to match the <Three-Letters>-<Number> format
    local pattern = "([a-zA-Z]+%-%d+)"

    -- Search for the pattern in the branch name
    local issue_id = string.match(branch_name, pattern)

    -- If an issue ID is found, return it in uppercase, otherwise return nil
    return issue_id and string.upper(issue_id) or nil
end

return M
