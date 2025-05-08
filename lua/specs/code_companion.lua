---@type LazyPluginSpec
return {
    "olimorris/codecompanion.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
        -- "ravitemer/codecompanion-history.nvim",
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
        adapters = {
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
        },
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
        -- extensions = {
        --     history = {
        --         enabled = true,
        --         opts = {
        --             -- Keymap to open history from chat buffer (default: gh)
        --             keymap = "gh",
        --             -- Automatically generate titles for new chats
        --             auto_generate_title = true,
        --             ---On exiting and entering neovim, loads the last chat on opening chat
        --             continue_last_chat = false,
        --             ---When chat is cleared with `gx` delete the chat from history
        --             delete_on_clearing_chat = false,
        --             -- Picker interface ("telescope" or "default")
        --             picker = "snacks",
        --             ---Enable detailed logging for history extension
        --             enable_logging = false,
        --             ---Directory path to save the chats
        --             dir_to_save = vim.fn.stdpath("data") .. "/codecompanion-history",
        --         },
        --     },
        -- },
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
                        -- name = "anthropic",
                        -- model = "claude-3-7-sonnet-20250219",
                        -- model = "claude-3-5-haiku-20241022",
                        name = "openai",
                        model = "gpt-4.1",
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
                                .. "If you encounter variable names or other code elements, please wrap them in backticks."
                                .. "Consider the path of files changed for scope determination."

                            if commit_messages ~= "" and not commit_messages:match("fatal") then
                                template = template
                                    .. "\n\nPrevious commits in this feature branch (most recent first):"
                                    .. "\n```\n"
                                    .. commit_messages
                                    .. "\n```"
                                    .. "\nPlease ensure the new commit message is consistent with and builds upon these previous commits."
                                    .. "Keep in mind that the lines should not exceed 72 characters."
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
