# Neovim Configuration Helper

## Commands
- Check Lua formatting: `stylua --check .`
- Format Lua code: `stylua .`
- Install missing plugins: `:Lazy install`
- Update plugins: `:Lazy update`
- Lint current file: `:lua vim.diagnostics.lint()`
- Format current buffer: `:lua vim.lsp.buf.format()`

## Code Style
- Indentation: 4 spaces
- Line length: 125 characters max
- Quotes: Prefer double quotes
- Always use parentheses for function calls
- Module pattern: `local M = {}; function M.setup() end; return M`
- Plugin specs use LazyPluginSpec type
- Types: Use ---@type annotations
- Namespace: All custom modules under `nbr.*` namespace
- Error handling: Use pcall pattern for potentially failing calls

## Project Structure
- Plugin specs: `lua/nbr/specs/*.lua`
- Core config: `lua/nbr/{config,options,keymaps,lazy}.lua`
- Utilities: `lua/nbr/lib/*.lua`