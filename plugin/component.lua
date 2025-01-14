---@class component-nvim.Config
---@field projects component-nvim.Project[]

---@class component-nvim.Project
---@field root_folder string
---@field recognition_pattern string
---@field extensions string[]

local M = {}

---@type component-nvim.Config
M.config = {
    projects = {
        {
            root_folder = "bc-desktop-client",
            recognition_pattern = "src/*/**/*components/**/*.tsx",
            extensions = { "tsx", "scss", "story.tsx" },
        },
    },
}

local function close_all_windows_except_current()
    local current_win = vim.api.nvim_get_current_win()
    local all_wins = vim.api.nvim_tabpage_list_wins(0)
    for _, win in ipairs(all_wins) do
        if win ~= current_win then
            vim.api.nvim_win_close(win, true)
        end
    end
end

---@param str string
local function trim_newline(str)
    return str:gsub("\n", "")
end

---Get the current project configuration based on the project path.
---@param projects component-nvim.Project[]
---@return component-nvim.Project | nil
local function get_current_project_config(projects)
    local current_working_dir = vim.fn.system("git rev-parse --show-toplevel")

    if current_working_dir == "" then
        print("No git repository found")
        return nil
    end

    local project_folder = vim.fn.fnamemodify(trim_newline(current_working_dir), ":t")

    -- for _, config in ipairs(M.config.projects) do
    for _, project in ipairs(projects) do
        if project.root_folder == project_folder then
            return project
        end
    end

    print("No matching project config found")
    return nil
end

-- TODO: provide starting path (e.g. src/components)
---@param extension string
---@param name string
local function find_files_by_extension_and_name(extension, name)
    local filePath = vim.fn.system(string.format("rg --files --hidden --glob '%s.%s'", name, extension))
    return trim_newline(filePath)
end

---@param component_name string
---@param extensions string[]
local function open_files_by_type(component_name, extensions)
    local all_wins
    local first_file = true -- To keep track of the first file

    for _, ext in ipairs(extensions) do
        local file_path = find_files_by_extension_and_name(ext, component_name)

        if file_path ~= "" then
            if first_file then -- Open first file with edit
                vim.cmd(string.format("edit %s", file_path))
                first_file = false
            else
                vim.cmd(string.format("vsplit %s", file_path))
            end
        end

        all_wins = vim.api.nvim_tabpage_list_wins(0)
    end

    -- Focus the first window
    if #all_wins > 0 then
        vim.api.nvim_set_current_win(all_wins[1])
    end
end

-- TODO: provide starting path
---@param recognition_pattern string
local function find_items(recognition_pattern)
    local rg_string = string.format("rg --files --hidden -g '%s'", recognition_pattern)
    local rg_output = vim.fn.system(rg_string)

    local files = vim.split(rg_output, "\n")
    local unique_items = {}

    for _, file in ipairs(files) do
        local pattern = string.format(".+/([^/.]+)%%.%s$", recognition_pattern:match("[^.]+$"))
        local item = file:match(pattern)
        if item then
            unique_items[item] = true
        end
    end

    local item_names = {}

    for name, _ in pairs(unique_items) do
        table.insert(item_names, name)
    end

    table.sort(item_names)

    return item_names
end

---@param config component-nvim.Config
function M.find_and_open_files(config)
    local project_config = get_current_project_config(config.projects)

    if not project_config then
        return
    end

    local item_names = find_items(project_config.recognition_pattern)

    if #item_names == 0 then
        print("No items found")
    else
        vim.ui.select(item_names, { prompt = "Select an item:" }, function(selected_item)
            if selected_item then
                vim.ui.select({ "No", "Yes" }, { prompt = "Open in new tab?" }, function(selected)
                    if selected == "Yes" then
                        vim.cmd.tabnew()
                        open_files_by_type(selected_item, project_config.extensions)
                    else
                        close_all_windows_except_current()
                        open_files_by_type(selected_item, project_config.extensions)
                    end
                end)
            end
        end)
    end
end

---Find and open a component file under the cursor in a new tab.
---@param config component-nvim.Config
---@param component_name? string
function M.find_and_open_component_file(config, component_name)
    component_name = component_name or vim.fn.expand("<cword>")

    local project_config = get_current_project_config(config.projects)

    if not project_config then
        print("No project config found")
        return
    end

    if not component_name then
        print("No component name found")
    else
        for _, ext in ipairs(project_config.extensions) do
            local path = find_files_by_extension_and_name(ext, component_name)

            if path ~= "" then
                vim.ui.select({ "No", "Yes" }, { prompt = "Open component in a new tab?" }, function(choice)
                    if choice == "Yes" then
                        vim.cmd.tabnew()
                        open_files_by_type(component_name, project_config.extensions)
                    else
                        close_all_windows_except_current()
                        open_files_by_type(component_name, project_config.extensions)
                    end
                end)

                return
            else
                print("No component found for " .. component_name)
            end
        end
    end
end

function M.setup()
    -- vim.keymap.set("n", "sc", function()
    --     M.find_and_open_files(M.config)
    -- end, { desc = "Component" })

    vim.keymap.set("n", "gC", function()
        M.find_and_open_component_file(M.config)
    end, { desc = "Component under cursor" })
end

M.setup()
