---@type LazyPluginSpec
return {
    "olimorris/codecompanion.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
        "ravitemer/codecompanion-history.nvim",
    },
    cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions", "CodeCompanionHistory" },
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
            anthropic_sonnet_3_7_no_reason = function()
                return require("codecompanion.adapters").extend("anthropic", {
                    name = "anthropic_sonnet_3_7_no_reason", -- Give this adapter a different name to differentiate it from the default adapter
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
            copilot_anthropic_sonnet_3_7 = function()
                return require("codecompanion.adapters").extend("copilot", {
                    schema = {
                        model = {
                            default = "claude-3.7-sonnet",
                        },
                    },
                })
            end,
            copilot_anthropic_sonnet_4 = function()
                return require("codecompanion.adapters").extend("copilot", {
                    schema = {
                        model = {
                            default = "claude-sonnet-4",
                        },
                    },
                })
            end,
            copilot_google_gemini_2_5 = function()
                return require("codecompanion.adapters").extend("copilot", {
                    schema = {
                        model = {
                            default = "gemini-2.5-pro",
                        },
                    },
                })
            end,
            copilot_openai_gpt_4_1 = function()
                return require("codecompanion.adapters").extend("copilot", {
                    schema = {
                        model = {
                            default = "gpt-4.1",
                        },
                    },
                })
            end,
        },
        strategies = {
            chat = {
                -- adapter = "anthropic_sonnet_3_7_no_reason",
                -- adapter = "copilot_openai_gpt_4_1",
                adapter = "copilot_anthropic_sonnet_4",
            },
            inline = {
                -- adapter = "anthropic_sonnet_3_7_no_reason",
                -- adapter = "copilot_openai_gpt_4_1",
                adapter = "copilot_anthropic_sonnet_4",
            },
        },
        extensions = {
            history = {
                enabled = true,
                ---@module "codecompanion._extensions.history"
                ---@type HistoryOpts
                opts = {
                    auto_save = false,
                    save_chat_keymap = "sc",
                    -- Keymap to open history from chat buffer (default: gh)
                    keymap = "gh",
                    -- Automatically generate titles for new chats
                    auto_generate_title = true,
                    ---On exiting and entering neovim, loads the last chat on opening chat
                    continue_last_chat = false,
                    ---When chat is cleared with `gx` delete the chat from history
                    delete_on_clearing_chat = false,
                    -- Picker interface ("telescope" or "default")
                    picker = "snacks",
                    ---Enable detailed logging for history extension
                    enable_logging = false,
                    ---Directory path to save the chats
                    dir_to_save = vim.fn.stdpath("config") .. "/codecompanion-history",
                },
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
                    -- adapter = "copilot_openai_gpt_4_1",
                    adapter = "copilot_anthropic_sonnet_3_7",
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

                            local template = "You are an expert at following the Conventional Commit specification."
                                .. " Given the git diff listed below, generate a succinct commit message."
                                .. "\n- The summary line MUST NOT exceed 72 characters."
                                .. "\n- In most cases, the summary alone is sufficient; ONLY add a body if the change is complex or non-obvious."
                                .. "\n- If you do add a body, it should be concise and use bullet points."
                                .. "\n- Wrap variable names or code elements in backticks."
                                .. "\n- Consider changed file paths for scope."
                                .. "\n- Omit explanations and return only the commit message text."

                            if commit_messages ~= "" and not commit_messages:match("fatal") then
                                template = template
                                    .. "\n\nPrevious commits in this feature branch (most recent first):"
                                    .. "\n```\n"
                                    .. commit_messages
                                    .. "\n```"
                                    .. "\nEnsure consistency with these commits. Adhere to the 72-character summary rule."
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
            "<leader>aih",
            "<CMD>CodeCompanionHistory<CR>",
            desc = "[H]istory",
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
