local M = {}

--- Implementation modeled after the lspconfig repository
--- https://raw.githubusercontent.com/TheRealLorenz/nvim-lspconfig/950e3d69092080a3d4d74e9d2515541afe56bfab/plugin/lspconfig.lua

--- Restart LSP servers
function M.restart()
    local bufnr = vim.api.nvim_get_current_buf()
    local clients = vim.lsp.get_clients({ bufnr = bufnr })

    if #clients == 0 then
        -- I'm using my own implementation of `vim.lsp.enable()`
        -- To work with default one change group name from `MyLsp` to `nvim.lsp.enable`
        -- It is not tested with default one, so not sure if it would 100% work.
        vim.api.nvim_exec_autocmds("FileType", { group = "MyLsp", buffer = bufnr })
        return
    end

    for _, c in ipairs(clients) do
        local attached_buffers = vim.tbl_keys(c.attached_buffers) ---@type integer[]
        local config = c.config
        vim.lsp.stop_client(c.id, true)
        vim.defer_fn(function()
            local id = vim.lsp.start(config)
            if id then
                for _, b in ipairs(attached_buffers) do
                    vim.lsp.buf_attach_client(b, id)
                end
                vim.notify(string.format("Lsp `%s` has been restarted.", config.name))
            else
                vim.notify(string.format("Error restarting `%s`.", config.name), vim.log.levels.ERROR)
            end
        end, 600)
    end
end

--- Display detailed information about active LSP clients
function M.info()
    -- Create a new buffer in a floating window
    local buf = vim.api.nvim_create_buf(false, true)
    local width = math.min(vim.o.columns - 4, 100)
    local height = math.min(vim.o.lines - 4, 30)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    local opts = {
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        style = "minimal",
        border = "rounded",
        title = " LSP Information ",
        title_pos = "center",
    }

    local win = vim.api.nvim_open_win(buf, true, opts)
    vim.wo[win].wrap = true
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].filetype = "markdown"

    -- Gather info about active clients
    local clients = vim.lsp.get_clients()
    local lines = { "# Active LSP Clients", "" }

    if vim.tbl_isempty(clients) then
        table.insert(lines, "No active clients")
    else
        for _, client in ipairs(clients) do
            table.insert(lines, "## " .. client.name .. " (id: " .. client.id .. ")")
            table.insert(lines, "")

            -- Basic client info
            table.insert(lines, "- **Root directory**: " .. (client.config.root_dir or "Not set"))

            -- Handle cmd which might be a function or table
            local cmd_str = "Unknown"
            if type(client.config.cmd) == "table" then
                -- Create a temporary array to store string representations
                local cmd_parts = {}
                for _, part in ipairs(client.config.cmd) do
                    table.insert(cmd_parts, tostring(part))
                end
                cmd_str = table.concat(cmd_parts, " ")
            elseif type(client.config.cmd) == "function" then
                cmd_str = "Function (dynamic)"
            end
            table.insert(lines, "- **Command**: `" .. cmd_str .. "`")

            -- Capabilities
            local caps = {}
            for cap, value in pairs(client.server_capabilities or {}) do
                if value == true then
                    table.insert(caps, cap)
                end
            end

            if #caps > 0 then
                table.insert(lines, "- **Capabilities**:")
                for _, cap in ipairs(caps) do
                    table.insert(lines, "  - " .. cap)
                end
            end

            -- Attached buffers
            local buffers = vim.lsp.get_buffers_by_client_id(client.id)
            if #buffers > 0 then
                table.insert(lines, "- **Attached buffers**:")
                for _, bufnr in ipairs(buffers) do
                    local name = vim.api.nvim_buf_get_name(bufnr)
                    if name ~= "" then
                        name = vim.fn.fnamemodify(name, ":~:.")
                    else
                        name = "[No Name]"
                    end
                    table.insert(lines, "  - " .. name .. " (buffer " .. bufnr .. ")")
                end
            end

            table.insert(lines, "")
        end
    end

    -- Add server configs info
    table.insert(lines, "# Available Server Configurations")
    table.insert(lines, "")

    local configs = {}
    for _, path in ipairs(vim.api.nvim_get_runtime_file("lsp/*.lua", true)) do
        table.insert(configs, vim.fn.fnamemodify(path, ":t:r"))
    end

    if #configs > 0 then
        table.insert(lines, "- Available configs: " .. table.concat(configs, ", "))
    else
        table.insert(lines, "No server configurations found")
    end

    -- Set content
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    -- Set keymaps for the window
    vim.api.nvim_buf_set_keymap(buf, "n", "q", ":close<CR>", { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", ":close<CR>", { noremap = true, silent = true })
end

--- Open LSP log file in a new tab
function M.open_log()
    local log_file = vim.lsp.get_log_path()

    if vim.fn.filereadable(log_file) == 1 then
        vim.notify("Opening LSP log file: " .. log_file, vim.log.levels.INFO, { title = "LSP" })
        vim.cmd("tabnew " .. vim.fn.fnameescape(log_file))
    else
        vim.notify("LSP log file not found at: " .. log_file, vim.log.levels.ERROR, { title = "LSP" })
    end
end

-- Create commands
vim.api.nvim_create_user_command("LspRestart", function()
    M.restart()
end, {
    desc = "Restart LSP servers",
})

vim.api.nvim_create_user_command("LspInfo", function()
    M.info()
end, {
    desc = "Show LSP information",
})

vim.api.nvim_create_user_command("LspLog", function()
    M.open_log()
end, {
    desc = "Open LSP log file",
})

return M
