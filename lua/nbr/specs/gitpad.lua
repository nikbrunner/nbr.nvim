local M = {}

--- IDEA: Automatically append/sync the branch note to the PR description and YouTrack issue on every push.

---@type LazyPluginSpec
M.spec = {
    "yujinyuz/gitpad.nvim",
    opts = function()
        local cwd = vim.fn.getcwd()
        local does_include = string.find(cwd, "dealercenter-digital", 1, true)
        local dir = does_include and require("nbr.config").pathes.notes.work.dcd
            or require("nbr.config").pathes.notes.personal

        return {
            title = "Vinpad",
            border = "rounded",
            dir = dir .. "/Gitpad",
            on_attach = function(bufnr)
                vim.api.nvim_buf_set_keymap(bufnr, "n", "q", "<Cmd>wq<CR>", { noremap = true, silent = true })
            end,
        }
    end,
    config = function(_, opts)
        require("gitpad").setup(opts)
    end,
    keys = {
        {
            "<leader>np",
            function()
                require("gitpad").toggle_gitpad()
            end,
            desc = "Project",
        },
        {
            "<leader>nb",
            function()
                require("gitpad").toggle_gitpad_branch()
            end,
            desc = "Branch",
        },
        {
            "<leader>nd",
            function()
                local date_filename = "daily-" .. os.date("%Y-%m-%d.md")
                require("gitpad").toggle_gitpad({ filename = date_filename })
            end,
            desc = "Daily",
        },
        {
            "<leader>nf",
            function()
                local filename = vim.fn.expand("%:p") -- or just use vim.fn.bufname()
                if filename == "" then
                    vim.notify("empty bufname")
                    return
                end
                filename = vim.fn.pathshorten(filename, 2) .. ".md"
                require("gitpad").toggle_gitpad({ filename = filename })
            end,
            desc = "File",
        },
    },
}

return M.spec
