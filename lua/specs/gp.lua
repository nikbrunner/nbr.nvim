local M = {}

---@type LazyPluginSpec
M.spec = {
    "robitx/gp.nvim",
    event = "VeryLazy",
    enabled = false,
    opts = {
        ---@diagnostic disable-next-line: param-type-mismatch
        state_dir = vim.fn.stdpath("config"):gsub("/$", "") .. "/gp/persisted",
        ---@diagnostic disable-next-line: param-type-mismatch
        chat_dir = vim.fn.stdpath("config"):gsub("/$", "") .. "/gp/chats",

        providers = {
            openai = {
                endpoint = "https://api.openai.com/v1/chat/completions",
                secret = os.getenv("OPENAI_API_KEY"),
            },
            anthropic = {
                endpoint = "https://api.anthropic.com/v1/messages",
                secret = os.getenv("ANTHROPIC_API_KEY"),
            },
        },

        default_command_agent = "ChatClaude-3-7-Sonnet",
        default_chat_agent = "ChatClaude-3-7-Sonnet",

        style_popup_border = "solid",

        -- chat_shortcut_respond = { modes = { "n", "i", "v", "x" }, shortcut = "<C-e><C-e>" },
        -- chat_shortcut_delete = { modes = { "n", "i", "v", "x" }, shortcut = "<C-e>d" },
        -- chat_shortcut_stop = { modes = { "n", "i", "v", "x" }, shortcut = "<C-e>s" },
        -- chat_shortcut_new = { modes = { "n", "i", "v", "x" }, shortcut = "<C-e>c" },

        hooks = {
            -- example of adding command which writes unit tests for the selected code
            UnitTests = function(gp, params)
                local template = "I have the following code from {{filename}}:\n\n"
                    .. "```{{filetype}}\n{{selection}}\n```\n\n"
                    .. "Please respond by writing table driven unit tests for the code above."
                local agent = gp.get_command_agent()
                gp.Prompt(params, gp.Target.vnew, agent, template)
            end,

            CommitMessage = function(gp, params)
                local has_staged_changes = vim.fn.system("git diff --staged") ~= ""

                if not has_staged_changes then
                    vim.notify(
                        "Error while generating commit message: No staged changes found"
                            .. "\n\n"
                            .. "Please stage your changes before running this command.",
                        vim.log.levels.ERROR
                    )
                    return
                end

                -- First, get the current branch name
                local current_branch = vim.fn.system("git rev-parse --abbrev-ref HEAD"):gsub("%s+", "")
                -- Get the default branch (trying both main and master)
                local base_branch = vim.fn.system("git rev-parse --verify main 2>/dev/null") ~= "" and "main" or "master"

                -- Get commits since branching off
                local commit_messages =
                    vim.fn.system(string.format("git log --format='%%s%%n%%b' %s..HEAD 2>/dev/null", base_branch))

                -- If the above failed, try getting just the last few commits
                if commit_messages:match("fatal") then
                    commit_messages = vim.fn.system("git log -3 --format='%s%n%b' 2>/dev/null")
                end

                local base_template = "You are an expert at following the Conventional Commit specification."
                    .. "Given the git diff listed below, please generate a detailed commit message for me and return it to me directly without explanation:"
                    .. "Use the summary line to describe the overall change, followed by an empty line, and then a more detailed, consice description of the change in the body in bullet points."
                    .. "Keep in mind that the summary line should not exceed 72 characters."
                    .. "Use as litte bullet points as possible. We want to keep the commit message short and concise."
                    .. "If you encounter variable names or other code elements, please wrap them in backticks. (e.g. `<var-name>`)"
                    .. "When asserting the scope, consider if it makes most sense to include the file name or the folder scope by looking at the pathes of the files changed."
                    .. "In most cases, the summary is enough to describe the overall change. Use the body only if the summary is not enough to describe the change."
                    .. "If the commit affects multiple files, consider the pathes of the files changed for the scope."
                    .. "If the commit only affects a single file, or one file has the main role in the change, please use the following format:"
                    .. "- feat|fix|docs|style|refactor|test|chore|revert(<affected-file (without file-extension) or scope>): description"
                    .. "In the bullet points, use the following format:"
                    .. "- feat|fix|docs|style|refactor|test|chore|revert(<affected-file (without file-extension) or scope>): description"
                    .. "If the previous commits follow a different scope terminology, please adapt to that terminology."

                if commit_messages ~= "" and not commit_messages:match("fatal") then
                    base_template = base_template
                        .. "\n\nPrevious commits in this feature branch (most recent first):"
                        .. "\n```\n"
                        .. commit_messages
                        .. "\n```"
                        .. "\nPlease ensure the new commit message is consistent with and builds upon these previous commits."
                end

                base_template = base_template
                    .. "\n\nChanges to commit:"
                    .. "\n```\n"
                    .. vim.fn.system("git diff --cached")
                    .. "\n```"

                local template = base_template

                -- If the branch name includes an issue ticket number, we use it to prefix the commit message.
                -- Example: bcd-1234-some-new-feature -> BCD-1234 feat: some new feature
                local issue_id = string.match(current_branch, "^bcd%-(%d%d%d%d)")
                local prefix = issue_id and "BCD-" .. issue_id .. " " or ""

                if issue_id then
                    template = base_template
                        .. "\n\n"
                        .. "Please prefix the summary line with the following issue ID: "
                        .. prefix
                        .. "\n\n"
                        .. "Example: BCD-1234 feat: some new feature"
                end

                local agent = gp.get_command_agent("ChatClaude-3-5-Sonnet")
                -- create horizontal split window with 30 height
                vim.api.nvim_command("split")
                vim.api.nvim_command("resize 20")
                gp.Prompt(params, gp.Target.enew, agent, template)
            end,

            -- TODO: This does not work yet
            -- example of usig enew as a function specifying type for the new buffer
            CodeReview = function(gp, params)
                local template = "I have the following code from {{filename}}:\n\n"
                    .. "```{{filetype}}\n{{selection}}\n```\n\n"
                    .. "Please analyze for code smells and suggest improvements."
                local agent = gp.get_chat_agent()
                gp.Prompt(params, gp.Target.vnew("markdown"), agent, template)
            end,

            Explain = function(gp, params)
                local template = "I have the following code from {{filename}}:\n\n"
                    .. "```{{filetype}}\n{{selection}}\n```\n\n"
                    .. "Please respond by explaining the code above."
                local agent = gp.get_chat_agent()
                gp.Prompt(params, gp.Target.popup, agent, template)
            end,

            WriteTests = function(gp, params)
                local template = "I have the following code from {{filename}}:\n\n"
                    .. "```{{filetype}}\n{{selection}}\n```\n\n"
                    .. "Please respond by writing unit tests for the code above."
                    .. "Put negative tests first, then positive tests."
                local agent = gp.get_command_agent()
                gp.Prompt(params, gp.Target.vnew("markdown"), agent, template)
            end,

            -- example of making :%GpChatNew a dedicated command which
            -- opens new chat with the entire current buffer as a context
            BufferChatNew = function(gp, _)
                -- call GpChatNew command in range mode on whole buffer
                vim.cmd.vsplit()
                vim.api.nvim_command("%" .. gp.config.cmd_prefix .. "ChatNew")
            end,
        },

        agents = {
            {
                name = "ChatGPT4",
                chat = true,
                command = false,
                -- string with model name or table with model name and parameters
                -- model = { model = "gpt-4-1106-preview", temperature = 1.1, top_p = 1 },
                model = { model = "gpt-4o", temperature = 1.1, top_p = 1 },
                -- system prompt (use this to specify the persona/role of the AI)
                system_prompt = "You are a general AI assistant.\n\n"
                    .. "The user provided the additional info about how they would like you to respond:\n\n"
                    .. "- If you're unsure don't guess and say you don't know instead.\n"
                    .. "- Ask question if you need clarification to provide better answer.\n"
                    .. "- Think deeply and carefully from first principles step by step.\n"
                    .. "- Zoom out first to see the big picture and then zoom in to details.\n"
                    .. "- Use Socratic method to improve your thinking and coding skills.\n"
                    .. "- Don't elide any code from your output if the answer requires coding.\n"
                    .. "- Take a deep breath; You've got this!\n",
            },
            {
                provider = "anthropic",
                name = "ChatClaude-3-5-Sonnet",
                chat = true,
                command = false,
                model = { model = "claude-3-5-sonnet-20241022", temperature = 0.8, top_p = 1 },
                system_prompt = "You are a general AI assistant with expertise in coding.\n\n"
                    .. "Your main coding stack includes TypeScript, SCSS, CSS, JavaScript, HTML, and some Go.\n\n"
                    .. "Please adhere to these guidelines when responding:\n\n"
                    .. "- If unsure, admit you don't know rather than guessing.\n"
                    .. "- Ask for clarification when needed to provide better answers.\n"
                    .. "- Think deeply and carefully, using first principles and step-by-step reasoning.\n"
                    .. "- Start with a broad perspective before focusing on details.\n"
                    .. "- Use the Socratic method to enhance thinking and coding skills.\n"
                    .. "- When coding is required, provide complete code without omissions.\n"
                    .. "- Approach each task confidently - you've got this!",
            },
            {
                provider = "anthropic",
                name = "ChatClaude-3-7-Sonnet",
                chat = true,
                command = false,
                model = { model = "claude-3-7-sonnet-20250219", temperature = 0.8, top_p = 1 },
                system_prompt = "You are a general AI assistant with expertise in coding.\n\n"
                    .. "Your main coding stack includes TypeScript, SCSS, CSS, JavaScript, HTML, and some Go.\n\n"
                    .. "Please adhere to these guidelines when responding:\n\n"
                    .. "- If unsure, admit you don't know rather than guessing.\n"
                    .. "- Ask for clarification when needed to provide better answers.\n"
                    .. "- Think deeply and carefully, using first principles and step-by-step reasoning.\n"
                    .. "- Start with a broad perspective before focusing on details.\n"
                    .. "- Use the Socratic method to enhance thinking and coding skills.\n"
                    .. "- When coding is required, provide complete code without omissions.\n"
                    .. "- Approach each task confidently - you've got this!",
            },
        },
    },
    keys = {
        {
            "ga",
            ":<C-u>'<,'>GpChatPaste<cr>",
            desc = "Pase selection to chat",
            mode = "x",
        },
        {
            "<leader>ain",
            "<cmd>GpChatNew vsplit<cr>",
            desc = "[N]ew Chat",
        },
        {
            "<leader>aiN",
            "<cmd>GpBufferChatNew vsplit<cr>",
            desc = "[N]ew Chat (with Buffer)",
        },
        {
            "<leader>ait",
            "<cmd>GpChatToggle vsplit<cr>",
            desc = "[T]oggle Last Chat",
        },
        {
            "<leader>aif",
            "<cmd>GpChatFinder<cr>",
            desc = "[F]ind Chat",
        },
        {
            "<C-g>",
            ":<C-u>'<,'>GpRewrite<cr>",
            desc = "Inline Rewrite",
            mode = { "n", "x" },
        },
        {
            "<leader>aic",
            "<cmd>GpCommitMessage<cr>",
            desc = "[C]ommit Message",
        },
        {
            "<leader>aie",
            ":<C-u>'<,'>GpExplain<cr>",
            desc = "[E]xplain Code",
            mode = { "n", "x" },
        },
        {
            "<leader>air",
            ":<C-u>'<,'>GpCodeReview<cr>",
            desc = "[R]eview",
            mode = "x",
        },
        {
            "<leader>aiT",
            ":<C-u>'<,'>GpWriteTests<cr>",
            desc = "[T]ests",
            mode = "x",
        },
    },
    config = function(_, opts)
        require("gp").setup(opts)
    end,
}

return M.spec
