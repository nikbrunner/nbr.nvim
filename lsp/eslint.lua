-- Install with: npm i -g vscode-langservers-extracted

local eslint_configs = {
    ".eslintrc",
    ".eslintrc.js",
    ".eslintrc.json",
    "eslint.config.js",
    "eslint.config.mjs",
}

---@type vim.lsp.Config
return {
    cmd = { "vscode-eslint-language-server", "--stdio" },
    filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "graphql" },
    root_markers = eslint_configs,
    root_dir = function(bufnr, cb)
        local fname = vim.uri_to_fname(vim.uri_from_bufnr(bufnr))

        -- Only start ESLint if we find an ESLint config file
        local eslint_config = vim.fs.find(eslint_configs, { upward = true, path = fname })[1]

        if eslint_config then
            cb(vim.fn.fnamemodify(eslint_config, ":h"))
        end
        -- If no config found, cb is not called and LSP won't start
    end,
    -- Using roughly the same defaults as nvim-lspconfig: https://github.com/neovim/nvim-lspconfig/blob/d3ad666b7895f958d088cceb6f6c199672c404fe/lua/lspconfig/configs/eslint.lua#L70
    settings = {
        validate = "on",
        packageManager = nil,
        useESLintClass = false,
        experimental = { useFlatConfig = false },
        codeActionOnSave = { enable = false, mode = "all" },
        format = false,
        quiet = false,
        onIgnoredFiles = "off",
        options = {},
        rulesCustomizations = {},
        run = "onType",
        problems = { shortenToSingleLine = false },
        nodePath = "",
        workingDirectory = { mode = "location" },
        codeAction = {
            disableRuleComment = { enable = true, location = "separateLine" },
            showDocumentation = { enable = true },
        },
    },
    before_init = function(params, config)
        -- Set the workspace folder setting for correct search of tsconfig.json files etc.
        config.settings.workspaceFolder = {
            uri = params.rootPath,
            name = vim.fn.fnamemodify(params.rootPath, ":t"),
        }
    end,
    ---@type table<string, lsp.Handler>
    handlers = {
        ["eslint/openDoc"] = function(_, params)
            vim.ui.open(params.url)
            return {}
        end,
        ["eslint/probeFailed"] = function()
            vim.notify("LSP[eslint]: Probe failed.", vim.log.levels.WARN)
            return {}
        end,
        ["eslint/noLibrary"] = function()
            vim.notify("LSP[eslint]: Unable to load ESLint library.", vim.log.levels.WARN)
            return {}
        end,
    },
}
