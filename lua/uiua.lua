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
}

M.config = vim.deepcopy(M.defaults)

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.defaults, opts or {})
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
