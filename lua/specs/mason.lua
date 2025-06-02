local Config = require("config")

---@type LazyPluginSpec[]
return {
    {
        "mason-org/mason.nvim",
        event = "VimEnter",
        opts = {},
    },

    {
        -- This is only used for the `ensure_installed` option, which is not avaialable in the base mason.nvim plugin
        -- [Support ensure_installed directly in mason · Issue #1713 · williamboman/mason.nvim](https://github.com/williamboman/mason.nvim/issues/1713)
        -- https://github.com/williamboman/mason-lspconfig.nvim/blob/1a31f824b9cd5bc6f342fc29e9a53b60d74af245/lua/mason-lspconfig/install.lua
        "mason-org/mason-lspconfig.nvim",
        event = { "BufReadPost", "BufNewFile" },
        dependencies = "williamboman/mason.nvim",
        opts = {
            ensure_installed = Config.ensure_installed.servers,
        },
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
                                local version = package:get_latest_version()
                                package:install({ version = version })
                            end
                        end
                    end)
                end,
            })
        end,
    },
}
