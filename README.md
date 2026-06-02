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
  highlights = true,      -- link uiua's LSP semantic-token types to
                          -- standard highlight groups (see below)
}
```

### Highlighting

Two layers, complementary:

- **`syntax/uiua.vim`** — a regex base layer that colours glyphs by arity,
  comments, strings and numbers. Works instantly and with no `uiua` binary.
- **`uiua lsp` semantic tokens** — a precise overlay that distinguishes
  noadic / monadic / dyadic / triadic / tetradic functions, modifiers and
  modules. More accurate and always matches your installed `uiua` version.

Colourschemes don't style uiua's custom `@lsp.type.*` groups, so with
`highlights = true` (default) this plugin links them to standard groups
(`Function`, `Operator`, `Keyword`, …). Set `highlights = false` to opt out, or
define your own links — `default = true` means yours always win:

```lua
vim.api.nvim_set_hl(0, "@lsp.type.dyadic_function", { fg = "#89b4fa" })
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
