-- Buffer-local setup for Uiua files.
vim.bo.commentstring = "# %s"
vim.bo.comments = ":#"

vim.bo.expandtab = true

local ok, uiua = pcall(require, "uiua")
if not ok then
  return
end

uiua.start_lsp(0)

-- :UiuaFormat for on-demand formatting.
vim.api.nvim_buf_create_user_command(0, "UiuaFormat", function()
  uiua.format(0)
end, { desc = "Format the buffer with `uiua fmt`" })

-- Format on save (set `vim.g.uiua_format_on_save = false` to disable).
if vim.g.uiua_format_on_save ~= false then
  vim.api.nvim_create_autocmd("BufWritePre", {
    group = vim.api.nvim_create_augroup("UiuaFormatOnSave", { clear = false }),
    buffer = 0,
    desc = "Format Uiua file before writing",
    callback = function(args)
      require("uiua").format(args.buf)
    end,
  })
end
