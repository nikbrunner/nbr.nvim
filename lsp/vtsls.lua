-- Install with: @vtsls/language-server
-- https://github.com/MariaSolOs/dotfiles/blob/main/.config/nvim/lsp/vtsls.lua

local shared_jsts_settings = {
    suggest = { completeFunctionCalls = true },
    inlayHints = {
        functionLikeReturnTypes = { enabled = true },
        parameterNames = { enabled = "literals" },
        variableTypes = { enabled = true },
    },
}

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
    filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
    init_options = {
        ---@see https://github.com/typescript-language-server/typescript-language-server#initializationoptions
        preferences = {
            importModuleSpecifierPreference = "relative",
        },
    },
    root_dir = function(bufnr, cb)
        local fname = vim.uri_to_fname(vim.uri_from_bufnr(bufnr))

        local deno_configs = { "deno.json", "deno.jsonc" }
        local deno_config = vim.fs.find(deno_configs, { upward = true, path = fname })[1]
        -- If there is a Deno config, we don't start the vtsls server.
        if deno_config then
            return
        end

        -- Use the git root to deal with monorepos where TypeScript is installed in the root node_modules folder.
        local git_root = vim.fs.find(".git", { upward = true, path = fname })[1]
        if git_root then
            cb(vim.fn.fnamemodify(git_root, ":h"))
        end

        local ts_configs = { "tsconfig.json", "tsconfig.jsonc" }
        local ts_config = vim.fs.find(ts_configs, { upward = true, path = fname })[1]
        if ts_config then
            cb(vim.fn.fnamemodify(ts_config, ":h"))
        end
    end,
    on_attach = function(client, bufnr)
        -- Cache the code action kind for better performance
        local add_missing_imports_kind = "source.addMissingImports.ts"

        -- Create autocmd group to ensure cleanup
        local group = vim.api.nvim_create_augroup("vtsls_auto_import_" .. bufnr, { clear = true })

        -- Set up autocmd to run add missing imports on save
        vim.api.nvim_create_autocmd("BufWritePre", {
            group = group,
            buffer = bufnr,
            callback = function()
                -- Early return if client is not active
                if not client or not client.request_sync then
                    return
                end

                -- Use vim.lsp.buf.code_action with a filter for better integration
                vim.lsp.buf.code_action({
                    context = {
                        only = { add_missing_imports_kind },
                        diagnostics = {},
                    },
                    filter = function(action)
                        return action.kind == add_missing_imports_kind
                    end,
                    apply = true,
                })
            end,
            desc = "vtsls: Add missing imports on save",
        })

        -- Clean up autocmd when buffer is deleted
        vim.api.nvim_create_autocmd("BufDelete", {
            group = group,
            buffer = bufnr,
            callback = function()
                vim.api.nvim_del_augroup_by_id(group)
            end,
        })

        vim.notify("Attached to vtsls with auto-import on save", vim.log.levels.INFO, { title = "vtsls" })
    end,
    settings = {
        typescript = shared_jsts_settings,
        javascript = shared_jsts_settings,
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
