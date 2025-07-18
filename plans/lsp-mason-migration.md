# LSP Configuration Migration to Mason.nvim

## Current Setup Analysis

### Architecture
- Using `vim.lsp.enable()` with custom LSP configs in `lsp/` directory
- LSP configs are discovered at runtime: `vim.api.nvim_get_runtime_file("lsp/*.lua", true)`
- Each LSP has its own config file with full vim.lsp.Config specification
- Custom logic for root directory detection to prevent unwanted LSP attachments

### Current LSP Configurations

1. **vtsls** (TypeScript/JavaScript)
   - Custom root_dir that excludes Deno projects
   - Auto-import on save functionality
   - VS Code TypeScript SDK detection
   - Custom settings for inlay hints and completions

2. **biome**
   - Simple root pattern for biome.json/biome.jsonc
   - Workspace required, no single file support

3. **eslint**
   - Root pattern for various eslint config formats
   - Custom handlers for eslint-specific LSP methods
   - Workspace folder configuration

4. **tailwindcss**
   - Root pattern for tailwind/postcss configs
   - Custom class attributes and functions

5. **Others** (bashls, cssls, denols, gopls, jsonls, lua_ls, markdown)
   - Various levels of customization

### Current Issues
- Cannot share utility functions between LSP configs due to runtime loading context
- Duplication of root_dir pattern logic
- Manual installation of LSP servers required
- No automatic server management

## Target Setup with Mason

### Architecture
- Mason handles LSP server installation
- mason-lspconfig bridges Mason and nvim-lspconfig
- Use lspconfig's battle-tested defaults
- Override only specific settings needed
- Centralized configuration in one file

### Implementation Steps

#### Phase 1: Install and Basic Setup
1. Add mason.nvim and mason-lspconfig.nvim to plugin specs
2. Create `lua/specs/mason.lua` for plugin configuration
3. Set up basic Mason UI and keybindings

#### Phase 2: Server Migration
1. Create mapping of current LSP names to Mason package names:
   - vtsls → vtsls
   - biome → biome
   - eslint → eslint (from vscode-langservers-extracted)
   - tailwindcss → tailwindcss-language-server
   - bashls → bash-language-server
   - cssls → css-lsp
   - denols → deno
   - gopls → gopls
   - jsonls → json-lsp
   - lua_ls → lua-language-server
   - markdown → marksman

2. Configure automatic installation of these servers

#### Phase 3: Custom Configuration Migration

Create setup handlers that preserve custom logic:

```lua
require("mason-lspconfig").setup_handlers({
  -- Default handler for most servers
  function(server_name)
    require("lspconfig")[server_name].setup({
      capabilities = capabilities,
      on_attach = on_attach,
    })
  end,
  
  -- Custom handlers for servers with special configs
  ["vtsls"] = function()
    require("lspconfig").vtsls.setup({
      on_attach = function(client, bufnr)
        -- Migrate auto-import functionality
        on_attach(client, bufnr)
        setup_vtsls_auto_import(client, bufnr)
      end,
      root_dir = custom_vtsls_root_dir,
      settings = { ... },
    })
  end,
})
```

#### Phase 4: Feature Preservation

1. **Auto-import on save for vtsls**
   - Extract to a separate function
   - Call in custom on_attach

2. **Root directory logic**
   - vtsls: Exclude Deno projects, use git root fallback
   - Others: Use lspconfig defaults where possible

3. **Custom settings**
   - Migrate all custom settings to the setup handlers
   - Preserve handler functions (eslint)

#### Phase 5: Cleanup
1. Remove individual LSP config files from `lsp/` directory
2. Update `lua/lsp.lua` to remove vim.lsp.enable() logic
3. Test all language servers in real projects

## Benefits After Migration

1. **Automatic Installation**: New machines just need `nvim` - Mason installs servers
2. **Simpler Configuration**: One file instead of many
3. **Better Defaults**: Leverage lspconfig's maintained defaults
4. **Easier Updates**: Mason handles server updates
5. **UI for Management**: `:Mason` provides nice UI for server management
6. **Shared Utilities**: Can use common functions since all config is in regular Lua context

## Configuration Structure After Migration

```
lua/
├── specs/
│   └── mason.lua          # Mason and mason-lspconfig setup
├── config/
│   └── lsp.lua           # Common LSP settings, on_attach, capabilities
└── lsp.lua               # Remove or simplify to just diagnostic config
```

## Rollback Plan

If issues arise:
1. Keep backup of current `lsp/` directory
2. Can run both systems in parallel during testing
3. Mason can be disabled while keeping lspconfig
4. Individual servers can be reverted to manual setup

## Testing Checklist

- [ ] TypeScript project with auto-import
- [ ] Deno project (should not start vtsls)
- [ ] Project with ESLint config
- [ ] Project with Biome config
- [ ] Tailwind CSS project
- [ ] Lua config files
- [ ] Go project
- [ ] Markdown files
- [ ] JSON with schemas
- [ ] Bash scripts

## Notes

- Current `vim.lsp.enable()` approach is newer but less common
- Mason approach is battle-tested in the community
- Can still have full control over each LSP configuration
- Migration can be done incrementally if needed