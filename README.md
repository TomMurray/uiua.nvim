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

## Installation

With [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "TomMurray/uiua.nvim",
  ft = "uiua",
  opts = {},
}
```

The `opts` table is passed to `require("uiua").setup()`. For other plugin
managers, call it yourself: `require("uiua").setup({ ... })`.

## Options

Defaults shown:

```lua
opts = {
  format_on_save = true,  -- run `uiua fmt` before each write
  lsp = true,             -- attach the official `uiua lsp` server
  server = {},            -- extra config merged into vim.lsp.start
                          -- (e.g. on_attach, capabilities, root_dir)
}
```

Example — turn off format on save and add an `on_attach`:

```lua
opts = {
  format_on_save = false,
  server = {
    on_attach = function(client, bufnr)
      -- your keymaps …
    end,
  },
}
```

## Commands

- `:UiuaFormat` — format the current buffer on demand
