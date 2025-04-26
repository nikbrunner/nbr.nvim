-- Install with: @vtsls/language-server
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#vtsls

local jsts_settings = {
    suggest = { completeFunctionCalls = true },
    inlayHints = {
        functionLikeReturnTypes = { enabled = true },
        parameterNames = { enabled = "literals" },
        variableTypes = { enabled = true },
    },
}

local deno_configs = {
    "deno.json",
    "deno.jsonc",
}

local ts_configs = {
    "tsconfig.json",
    "tsconfig.jsonc",
}

local filetypes = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
}

---@see https://github.com/MariaSolOs/dotfiles/blob/main/.config/nvim/lsp/vtsls.lua
local function get_global_tsdk()
    -- Use VS Code's bundled copy if available.
    local vscode_tsdk_path = "/Applications/%s/Contents/Resources/app/extensions/node_modules/typescript/lib"
    local vscode_tsdk = vscode_tsdk_path:format("Visual Studio Code.app")
    local vscode_insiders_tsdk = vscode_tsdk_path:format("Visual Studio Code - Insiders.app")

    if vim.fn.isdirectory(vscode_tsdk) == 1 then
        return vscode_tsdk
    elseif vim.fn.isdirectory(vscode_insiders_tsdk) == 1 then
        return vscode_insiders_tsdk
    else
        return nil
    end
end

---@type vim.lsp.Config
return {
    cmd = { "vtsls", "--stdio" },
    filetypes = filetypes,
    init_options = {
        ---@see https://github.com/typescript-language-server/typescript-language-server#initializationoptions
        preferences = {
            importModuleSpecifierPreference = "relative",
        },
    },
    root_dir = function(bufnr, cb)
        local fname = vim.uri_to_fname(vim.uri_from_bufnr(bufnr))

        -- If there is a Deno config, we don't start the vtsls server.
        local deno_config = vim.fs.find(deno_configs, { upward = true, path = fname })[1]
        if deno_config then
            return
        end

        -- Use the git root to deal with monorepos where TypeScript is installed in the root node_modules folder.
        local git_root = vim.fs.find(".git", { upward = true, path = fname })[1]
        if git_root then
            cb(vim.fn.fnamemodify(git_root, ":h"))
        end

        local ts_config = vim.fs.find(ts_configs, { upward = true, path = fname })[1]
        if ts_config then
            cb(vim.fn.fnamemodify(ts_config, ":h"))
        end
    end,
    on_attach = function()
        vim.notify("Attached to vtsls", vim.log.levels.INFO, { title = "vtsls" })
    end,
    settings = {
        typescript = jsts_settings,
        javascript = jsts_settings,
        vtsls = {
            typescript = {
                globalTsdk = get_global_tsdk(),
            },
            -- Automatically use workspace version of TypeScript lib on startup.
            autoUseWorkspaceTsdk = true,
            experimental = {
                -- Inlay hint truncation.
                maxInlayHintLength = 30,
                -- For completion performance.
                completion = {
                    enableServerSideFuzzyMatch = true,
                },
            },
        },
    },
}
