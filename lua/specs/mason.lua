local Config = require("config")

---@type LazyPluginSpec[]
return {
    {
        "williamboman/mason.nvim",
        event = "VimEnter",
        opts = {},
    },

    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        dependencies = "williamboman/mason.nvim",
        event = "VimEnter",
        opts = {
            ensure_installed = Config.ensure_installed.tools,
        },
        config = function(_, opts)
            vim.api.nvim_create_autocmd({ "VimEnter" }, {
                group = vim.api.nvim_create_augroup("mason-installer", { clear = true }),
                callback = function()
                    local registry = require("mason-registry")

                    -- https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim/issues/39
                    -- Ensure packages are installed and up to date
                    registry.refresh(function()
                        for _, name in pairs(opts.ensure_installed) do
                            local package = registry.get_package(name)
                            if not registry.is_installed(name) then
                                vim.notify(string.format("Installing %s", name), vim.log.levels.INFO, { title = "Mason" })
                                package:install()
                            else
                                package:check_new_version(function(success, result_or_err)
                                    if success then
                                        package:install({ version = result_or_err.latest_version })
                                    end
                                end)
                            end
                        end
                    end)
                end,
            })
        end,
    },
}
