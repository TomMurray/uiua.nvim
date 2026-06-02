local M = {}

-- Default options. Override via `require("uiua").setup({...})` — or, with
-- lazy.nvim, the `opts` table on the plugin spec.
M.defaults = {
  -- Run `uiua fmt` on the buffer before every write.
  format_on_save = true,
  -- Attach the official `uiua lsp` server (semantic highlighting, hover, …).
  lsp = true,
  -- Extra config merged into `vim.lsp.start` (e.g. on_attach, capabilities).
  server = {},
  -- Link uiua's custom LSP semantic-token types to standard highlight groups
  -- so the server's arity-aware colouring actually shows. Colourschemes don't
  -- style `@lsp.type.<uiua_*>` by default.
  highlights = true,
}

M.config = vim.deepcopy(M.defaults)

-- uiua lsp semantic-token type -> standard highlight group.
local SEMANTIC_LINKS = {
  uiua_number      = "Number",
  uiua_string      = "String",
  uiua_constant    = "Constant",
  noadic_function  = "Constant",
  monadic_function = "Function",
  dyadic_function  = "Operator",
  triadic_function = "Operator",
  tetradic_function = "Operator",
  stack_function   = "Delimiter",
  monadic_modifier = "Keyword",
  dyadic_modifier  = "PreProc",
  triadic_modifier = "PreProc",
  uiua_module      = "Include",
}

-- Link the custom `@lsp.type.<token>` groups. `default = true` so a user's own
-- definitions win. Must re-run after `:colorscheme` clears highlight groups.
function M.apply_highlights()
  if not M.config.highlights then
    return
  end
  for token, group in pairs(SEMANTIC_LINKS) do
    vim.api.nvim_set_hl(0, "@lsp.type." .. token, { link = group, default = true })
  end
end

-- One-time global wiring (idempotent): apply highlight links now and re-apply
-- whenever the colourscheme changes. Safe to call from both setup() and the
-- ftplugin, so it works even when setup() is never called.
function M.ensure_highlights()
  if M._hl_inited then
    return
  end
  M._hl_inited = true
  M.apply_highlights()
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("UiuaHighlights", { clear = true }),
    callback = function()
      M.apply_highlights()
    end,
  })
end

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.defaults, opts or {})
  M.ensure_highlights()
end

-- Format `bufnr` in place by piping its contents through `uiua fmt --io`.
-- Preserves cursor/scroll position and only touches the buffer if the
-- formatter actually changed something.
function M.format(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if vim.fn.executable("uiua") == 0 then
    return
  end

  local input = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local result = vim.system({ "uiua", "fmt", "--io" }, { stdin = input, text = true }):wait()

  if result.code ~= 0 then
    local msg = (result.stderr ~= "" and result.stderr) or "uiua fmt failed"
    vim.notify(msg, vim.log.levels.WARN, { title = "uiua" })
    return
  end

  local out = vim.split(result.stdout or "", "\n", { plain = true })
  -- `uiua fmt --io` emits a trailing newline -> drop the empty final element.
  if out[#out] == "" then
    table.remove(out)
  end

  if not vim.deep_equal(out, input) then
    local view = vim.fn.winsaveview()
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, out)
    vim.fn.winrestview(view)
  end
end

-- Attach the official Uiua language server (`uiua lsp`) for semantic
-- highlighting, hover, diagnostics, etc. No-op if disabled or uiua is missing.
function M.start_lsp(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not M.config.lsp or vim.fn.executable("uiua") == 0 then
    return
  end

  local cfg = vim.tbl_deep_extend("force", {
    name = "uiua",
    cmd = { "uiua", "lsp" },
    root_dir = vim.fs.root(bufnr, { ".git", "main.ua" }) or vim.fn.getcwd(),
  }, M.config.server or {})

  vim.lsp.start(cfg, { bufnr = bufnr })
end

return M
