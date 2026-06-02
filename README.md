# uiua.nvim

Minimal Neovim support for the [Uiua](https://www.uiua.org) array language.

- **Filetype** — `*.ua` → `uiua`
- **Syntax highlighting** — glyphs coloured by arity (monadic / dyadic functions,
  modifiers, stack ops), plus comments, strings, characters and numbers
- **Format on save** — pipes the buffer through `uiua fmt --io`, preserving
  cursor and scroll position
- **LSP** — attaches the official `uiua lsp` server for semantic highlighting,
  hover and diagnostics

## Requirements

The `uiua` binary on `$PATH` (`cargo install uiua`). Formatting and the LSP are
silently skipped if it is missing.

## Options (set before the plugin loads)

```lua
vim.g.uiua_format_on_save = false  -- disable format on save (default: enabled)
vim.g.uiua_lsp = false             -- disable the LSP client  (default: enabled)
```

## Commands

- `:UiuaFormat` — format the current buffer on demand
