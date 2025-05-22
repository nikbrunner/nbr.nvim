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

-- Create the LspRestart command
vim.api.nvim_create_user_command("LspRestart", function()
    M.restart()
end, {
    desc = "Restart LSP servers",
})

return M

