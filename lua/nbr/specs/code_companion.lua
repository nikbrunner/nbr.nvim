--- Define functions for saving and loading chats
local function save_path()
    local Path = require("plenary.path")
    local p = Path:new(vim.fn.stdpath("config") .. "/codecompanion_chats")
    p:mkdir({ parents = true })
    return p
end

-- We'll use this for the load functionality
local supported_adapters_for_loading = {
    "anthropic",
    "anthropic_no_reason",
}

-- Original adapter configuration
local supported_adapters = {
    anthropic_no_reason = function()
        return require("codecompanion.adapters").extend("anthropic", {
            name = "anthropic_no_reason", -- Give this adapter a different name to differentiate it from the default adapter
            schema = {
                model = {
                    -- NOTE: reasoning does not seem to work with inline assistant
                    choices = {
                        ["claude-3-7-sonnet-20250219"] = { opts = { can_reason = false } },
                    },
                },
            },
        })
    end,
}

--- Save the current codecompanion.nvim chat buffer to a file in the save_folder.
--- Usage: CodeCompanionSave <filename>.md
local function create_save_command()
    vim.api.nvim_create_user_command("CodeCompanionSave", function(opts)
        local codecompanion = require("codecompanion")
        local success, chat = pcall(function()
            return codecompanion.buf_get_chat(0)
        end)
        if not success or chat == nil then
            vim.notify("CodeCompanionSave should only be called from CodeCompanion chat buffers", vim.log.levels.ERROR)
            return
        end
        if #opts.fargs == 0 then
            vim.notify("CodeCompanionSave requires at least 1 arg to make a file name", vim.log.levels.ERROR)
            return
        end
        local timestamp = os.date("%Y%m%d-%H%M%S")
        local save_name = table.concat(opts.fargs, "-") .. "-" .. timestamp .. ".md"
        local save_file = save_path():joinpath(save_name)
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        save_file:write(table.concat(lines, "\n"), "w")
        vim.notify("Chat saved to " .. save_file:absolute(), vim.log.levels.INFO)
    end, { nargs = "*" })
end

--- Load a saved codecompanion.nvim chat file into a new CodeCompanion chat buffer.
--- Usage: CodeCompanionLoad
local function create_load_command()
    vim.api.nvim_create_user_command("CodeCompanionLoad", function()
        local function select_adapter(filepath)
            Snacks.picker.pick({
                source = "Select CodeCompanion Adapter",
                items = supported_adapters_for_loading,
                preview = false,
                layout = { preset = "flow" },
                confirm = function(picker, adapter)
                    -- Open new CodeCompanion chat with selected adapter
                    vim.cmd("CodeCompanionChat " .. adapter)

                    -- Read contents of saved chat file
                    local lines = vim.fn.readfile(filepath)

                    -- Get the current buffer (which should be the new CodeCompanion chat)
                    local current_buf = vim.api.nvim_get_current_buf()

                    -- Paste contents into the new chat buffer
                    vim.api.nvim_buf_set_lines(current_buf, 0, -1, false, lines)

                    picker:close()
                end,
            })
        end

        local files = vim.fn.glob(save_path():absolute() .. "/*", false, true)
        if #files == 0 then
            vim.notify("No saved chats found", vim.log.levels.INFO)
            return
        end

        -- Format items for snacks picker
        local items = {}
        for _, filepath in ipairs(files) do
            local filename = vim.fn.fnamemodify(filepath, ":t")
            table.insert(items, {
                text = filename,
                filepath = filepath,
                preview = { filepath = filepath },
            })
        end

        Snacks.picker.pick({
            source = "Saved CodeCompanion Chats",
            items = items,
            preview = "preview.filepath",
            layout = { preset = "default" },
            confirm = function(picker, item)
                select_adapter(item.filepath)
                picker:close()
            end,
            actions = {
                remove = function(picker)
                    local item = picker:get_item()
                    if item then
                        os.remove(item.filepath)
                        vim.notify("Removed " .. item.text, vim.log.levels.INFO)

                        -- Refresh the picker
                        local new_files = vim.fn.glob(save_path():absolute() .. "/*", false, true)
                        local new_items = {}
                        for _, filepath in ipairs(new_files) do
                            local filename = vim.fn.fnamemodify(filepath, ":t")
                            table.insert(new_items, {
                                text = filename,
                                filepath = filepath,
                                preview = { filepath = filepath },
                            })
                        end
                        picker:update({ items = new_items })
                    end
                end,
            },
            win = {
                input = {
                    keys = {
                        ["<c-r>"] = "actions.remove",
                    },
                },
                list = {
                    keys = {
                        ["<c-r>"] = "actions.remove",
                    },
                },
            },
        })
    end, {})
end

---@type LazyPluginSpec
return {
    "olimorris/codecompanion.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
    },
    event = "VeryLazy",
    opts = {
        display = {
            chat = {
                debug_window = {
                    ---@return number|fun(): number
                    width = vim.o.columns - 5,
                    ---@return number|fun(): number
                    height = vim.o.lines - 5,
                },
                window = {
                    layout = "vertical", -- float|vertical|horizontal|buffer
                    position = nil, -- left|right|top|bottom (nil will default depending on vim.opt.plitright|vim.opt.splitbelow)
                    border = "solid",
                    height = 0.35,
                },
            },
        },
        adapters = supported_adapters,
        strategies = {
            -- Change the default chat adapter
            chat = {
                adapter = "anthropic",
                slash_commands = {
                    ["file"] = {
                        callback = "strategies.chat.slash_commands.file",
                        description = "Select a file using Telescope",
                        opts = {
                            provider = "snacks",
                            contains_code = true,
                        },
                    },
                },
            },
            inline = {
                adapter = "anthropic_no_reason",
            },
        },
        prompt_library = {
            ["Generate a Commit Message"] = {
                strategy = "chat",
                description = "Generate a commit message",
                opts = {
                    index = 10,
                    is_default = true,
                    is_slash_cmd = true,
                    short_name = "commit",
                    auto_submit = true,
                    adapter = {
                        name = "anthropic",
                        -- model = "claude-3-7-sonnet-20250219",
                        model = "claude-3-5-haiku-20241022",
                    },
                },
                prompts = {
                    {
                        role = "user",
                        content = function()
                            -- Check for staged changes
                            if vim.fn.system("git diff --staged") == "" then
                                vim.notify(
                                    "Error while generating commit message: No staged changes found"
                                        .. "\n\n"
                                        .. "Please stage your changes before running this command.",
                                    vim.log.levels.ERROR
                                )

                                return nil
                            end

                            -- Get current branch
                            local current_branch = vim.fn.system("git rev-parse --abbrev-ref HEAD"):gsub("%s+", "")
                            -- Get last 5 commit messages from the current branch itself
                            local commit_messages = vim.fn.system("git log -n 10 --format='%s%n%b' HEAD 2>/dev/null")
                            if commit_messages:match("fatal") then
                                commit_messages = vim.fn.system("git log -10 --format='%s%n%b' 2>/dev/null")
                            end

                            -- Construct initial prompt template
                            local template = "You are an expert at following the Conventional Commit specification."
                                .. "Given the git diff listed below, please generate a detailed commit message for me and return it to me directly without explanation:"
                                .. "Use the summary line to describe the overall change, followed by an empty line, and then a more detailed, concise description of the change in the body in bullet points."
                                .. "Keep in mind that the summary line should not exceed 72 characters."
                                .. "If you encounter variable names or other code elements, please wrap them in backticks."
                                .. "Consider the path of files changed for scope determination."

                            if commit_messages ~= "" and not commit_messages:match("fatal") then
                                template = template
                                    .. "\n\nPrevious commits in this feature branch (most recent first):"
                                    .. "\n```\n"
                                    .. commit_messages
                                    .. "\n```"
                                    .. "\nPlease ensure the new commit message is consistent with and builds upon these previous commits."
                            end

                            -- Append changes to commit
                            template = template
                                .. "\n\nChanges to commit:"
                                .. "\n```\n"
                                .. vim.fn.system("git diff --cached")
                                .. "\n```"

                            -- Determine the issue ID prefix
                            local issue_id = string.match(current_branch, "^bcd%-(%d%d%d%d)")
                            if issue_id then
                                template = template
                                    .. "\n\nPlease prefix the summary line with the following issue ID: BCD-"
                                    .. issue_id
                                    .. "\n\nExample: BCD-"
                                    .. issue_id
                                    .. " feat: some new feature"
                            end

                            return template
                        end,
                        opts = {
                            contains_code = true,
                        },
                    },
                },
            },
        },
    },
    config = function(_, opts)
        require("codecompanion").setup(opts)

        -- Create commands for saving and loading chats
        create_save_command()
        create_load_command()
    end,
    keys = {
        {
            "<leader>ait",
            "<CMD>CodeCompanionChat Toggle<CR>",
            desc = "[C]hat",
        },
        {
            "<leader>ain",
            "<CMD>CodeCompanionChat<CR>",
            desc = "[C]hat",
        },
        {
            "<leader>aiC",
            "<CMD>CodeCompanion /commit<CR>",
            desc = "[C]ommit",
        },
        {
            "<leader>aia",
            "<CMD>CodeCompanionActions<CR>",
            mode = { "n", "x" },
            desc = "[A]ctions",
        },
        {
            "<leader>ais",
            "<CMD>CodeCompanionSave chat<CR>",
            desc = "[S]ave Chat",
        },
        {
            "<leader>ail",
            "<CMD>CodeCompanionLoad<CR>",
            desc = "[L]oad Chat",
        },
        {
            "<C-g>",
            ":<C-u>'<,'>CodeCompanion<CR>",
            desc = "Inline Rewrite",
            mode = { "n", "x" },
        },
        {
            "ga",
            ":<C-u>'<,'>CodeCompanionChat Add<CR>",
            desc = "Pase selection to chat",
            mode = "x",
        },
    },
}
