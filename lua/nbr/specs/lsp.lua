local State = require("nbr.state")
local Config = require("nbr.config")

local M = {}

---@type LazyPluginSpec[]
M.specs = {
    {
        "williamboman/mason.nvim",
        opts = {},
        ---@param opts MasonSettings | {ensure_installed: string[]}
        config = function(_, opts)
            require("mason").setup(opts)
        end,
    },

    {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
            library = {
                "lazy.nvim",
                "/luvit-meta/library",
                { path = "snacks.nvim", words = { "Snacks" } },
            },
        },
    },

    {
        "williamboman/mason-lspconfig.nvim",
        event = "VeryLazy",
        dependencies = {
            "williamboman/mason.nvim",
            "neovim/nvim-lspconfig",
            "folke/lazydev.nvim",
            "saghen/blink.cmp",
        },
        opts = function()
            local function setup_server(server_name, extra_opts)
                local capabilities = require("blink.cmp").get_lsp_capabilities()

                local opts = vim.tbl_extend("force", {
                    capabilities = capabilities,
                }, extra_opts or {})

                require("lspconfig")[server_name].setup(opts)
            end

            return {
                ensure_installed = Config.ensure_installed.servers,

                handlers = {
                    function(server_name)
                        setup_server(server_name)
                    end,

                    ts_ls = function()
                        setup_server("ts_ls", {
                            root_dir = require("lspconfig.util").root_pattern("package.json"),
                            single_file_support = false,
                            init_options = {
                                ---@see https://github.com/typescript-language-server/typescript-language-server#initializationoptions
                                preferences = {
                                    importModuleSpecifierPreference = "relative",
                                },
                            },
                            settings = {
                                typescript = {
                                    inlayHints = {
                                        includeInlayParameterNameHints = "literal",
                                        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                                        includeInlayFunctionParameterTypeHints = true,
                                        includeInlayVariableTypeHints = true,
                                        includeInlayPropertyDeclarationTypeHints = true,
                                        includeInlayFunctionLikeReturnTypeHints = true,
                                        includeInlayEnumMemberValueHints = true,
                                    },
                                },
                                javascript = {
                                    inlayHints = {
                                        includeInlayParameterNameHints = "all",
                                        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                                        includeInlayFunctionParameterTypeHints = true,
                                        includeInlayVariableTypeHints = true,
                                        includeInlayPropertyDeclarationTypeHints = true,
                                        includeInlayFunctionLikeReturnTypeHints = true,
                                        includeInlayEnumMemberValueHints = true,
                                    },
                                },
                            },
                        })
                    end,

                    -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#vtsls
                    vtsls = function()
                        setup_server("vtsls", {
                            root_dir = require("lspconfig.util").root_pattern("package.json"),
                            single_file_support = false,
                            settings = {
                                typescript = {
                                    tsserver = {
                                        maxTsServerMemory = 4000,
                                    },
                                    updateImportsOnFileMove = {
                                        enabled = "always",
                                    },
                                    suggest = {
                                        completeFunctionCalls = true,
                                    },
                                    inlayHints = {
                                        enumMemberValues = { enabled = true },
                                        functionLikeReturnTypes = { enabled = true },
                                        parameterNames = { enabled = "literals" },
                                        parameterTypes = { enabled = true },
                                        propertyDeclarationTypes = { enabled = true },
                                        variableTypes = { enabled = false },
                                    },
                                    preferences = {
                                        importModuleSpecifier = "relative",
                                    },
                                },
                            },
                        })
                    end,

                    -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#denols
                    denols = function()
                        setup_server("denols", {
                            root_dir = require("lspconfig.util").root_pattern("deno.json", "deno.jsonc"),
                            single_file_support = false,
                            on_attach = function()
                                State:set("is_deno_project", true)
                            end,
                        })
                    end,

                    harper_ls = function()
                        setup_server("harper_ls", {
                            settings = {
                                ["harper-ls"] = {
                                    userDictPath = vim.fn.stdpath("config") .. "/spell/en.utf-8.add",
                                    linters = {
                                        SentenceCapitalization = false,
                                        Spaces = false,
                                    },
                                },
                            },
                        })
                    end,

                    -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#lua_ls
                    ["lua_ls"] = function()
                        setup_server("lua_ls", {
                            settings = {
                                Lua = {
                                    workspace = {
                                        checkThirdParty = false,
                                    },
                                    telemetry = { enable = false },
                                    hint = { enable = true },
                                    codeLens = { enable = true },
                                    completion = { callSnippet = "Replace" },
                                },
                            },
                        })
                    end,

                    -- Configure `cssls` to avoid Tailwind projects
                    ["cssls"] = function()
                        setup_server("cssls", {
                            filetypes = { "css", "scss", "less" },
                            root_dir = function(fname)
                                local util = require("lspconfig.util")
                                -- Skip cssls for projects with a tailwind.config.js file
                                if util.root_pattern("tailwind.config.js")(fname) then
                                    return nil
                                end
                                return vim.fs.dirname(vim.fs.find(".git", { path = fname, upward = true })[1])
                                    or vim.fs.dirname(fname)
                            end,
                        })
                    end,
                },
            }
        end,
        config = function(_, opts)
            local icons = require("nbr.icons")

            local Severity = vim.diagnostic.severity

            vim.diagnostic.config({
                underline = false,
                virtual_text = false,
                virtual_lines = false,
                update_in_insert = false,
                float = {
                    border = "single",
                },
                signs = {
                    text = {
                        [Severity.ERROR] = icons.diagnostics.Error,
                        [Severity.WARN] = icons.diagnostics.Warn,
                        [Severity.INFO] = icons.diagnostics.Info,
                        [Severity.HINT] = icons.diagnostics.Hint,
                    },
                },
            })

            require("mason-lspconfig").setup(opts)
        end,
    },

    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        dependencies = "williamboman/mason.nvim",
        -- https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim/issues/39
        event = "VeryLazy",
        opts = {
            ensure_installed = Config.ensure_installed.tools,
        },
        config = function(_, opts)
            vim.api.nvim_create_autocmd({ "VimEnter" }, {
                group = vim.api.nvim_create_augroup("mason-installer", { clear = true }),
                callback = function()
                    local registry = require("mason-registry")

                    -- Ensure packages are installed and up to date
                    registry.refresh(function()
                        for _, name in pairs(opts.ensure_installed) do
                            local package = registry.get_package(name)
                            if not registry.is_installed(name) then
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

return M.specs
