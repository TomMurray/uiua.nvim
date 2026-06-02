local M = {}

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
  if vim.g.uiua_lsp == false or vim.fn.executable("uiua") == 0 then
    return
  end

  vim.lsp.start({
    name = "uiua",
    cmd = { "uiua", "lsp" },
    root_dir = vim.fs.root(bufnr, { ".git", "main.ua" }) or vim.fn.getcwd(),
  }, { bufnr = bufnr })
end

return M
