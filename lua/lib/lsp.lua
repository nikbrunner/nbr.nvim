local M = {}

--- Implementation modeled after the lspconfig repository
--- https://raw.githubusercontent.com/TheRealLorenz/nvim-lspconfig/950e3d69092080a3d4d74e9d2515541afe56bfab/plugin/lspconfig.lua

--- Restart LSP servers
function M.restart()
    vim.notify("Restarting LSP Servers", vim.log.levels.INFO, { title = "LSP" })

    -- Get existing clients
    local clients = vim.lsp.get_clients()

    -- Stop all clients
    for _, client in ipairs(clients) do
        vim.lsp.stop_client(client.id)
    end

    -- Wait briefly for clients to stop, then restart them
    vim.defer_fn(function()
        -- Load all server configs
        local server_configs = {}
        for _, config_path in ipairs(vim.api.nvim_get_runtime_file("lsp/*.lua", true)) do
            local name = vim.fn.fnamemodify(config_path, ":t:r")
            local ok, config = pcall(dofile, config_path)
            if ok and config then
                server_configs[name] = config
            end
        end

        -- Restart for current buffer
        vim.lsp.start({
            name = vim.bo.filetype .. "_ls",
            cmd = server_configs[vim.bo.filetype .. "_ls"] and server_configs[vim.bo.filetype .. "_ls"].cmd
                or server_configs[vim.bo.filetype] and server_configs[vim.bo.filetype].cmd
                or server_configs["lua_ls"].cmd, -- fallback
            root_dir = vim.fn.getcwd(),
        })

        vim.cmd("edit") -- Reload buffer to ensure attachment
    end, 500) -- 500ms delay to allow clients to shut down
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
