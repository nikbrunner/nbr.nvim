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
- Error handling: Use pcall pattern for potentially failing calls

## Project Structure

- Plugin specs: `lua/specs/*.lua`
- Core config: `lua/{config,options,keymaps,autocmd}.lua`
- Utilities: `lua/lib/*.lua`

## Pending Tasks

- Refine the CodeCompanion chat saving functionality:
  - Fix diagnostics in code_companion.lua
  - Test save/load functionality with different adapters
  - Consider adding timestamps to saved chats
  - Check file preview rendering in the Snacks picker
  - Store conversations in a structured format (not just raw buffer lines)
