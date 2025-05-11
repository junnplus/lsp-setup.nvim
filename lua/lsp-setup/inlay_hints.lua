local M = {}

---@class InlayHints.Options
---@field enabled? boolean Enable inlay hints
---@field highlight? string Highlight group for inlay hints
M.opts = {
  enabled = false,
  highlight = 'Comment',
}
M.state = setmetatable({}, { __index = nil })

---@param opts InlayHints.Options
function M.setup(opts)
  M.opts = vim.tbl_deep_extend('keep', opts, M.opts)
  if not opts.enabled then
    return
  end

  if vim.fn.has('nvim-0.11') ~= 1 then
    vim.notify_once('LSP Inlayhints requires Neovim 0.11.0+', vim.log.levels.ERROR)
    return
  end

  vim.cmd.highlight('default link LspInlayHint ' .. M.opts.highlight)

  vim.api.nvim_create_augroup('LspSetup_Inlayhints', {})
  vim.api.nvim_create_autocmd('LspAttach', {
    group = 'LspSetup_Inlayhints',
    callback = function(args)
      if not (args.data and args.data.client_id) then
        return
      end

      local bufnr = args.buf
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      M.on_attach(client, bufnr)
    end,
  })
end

---@param client vim.lsp.Client|nil
---@param bufnr number
---@return nil
function M.on_attach(client, bufnr)
  if not client then
    vim.notify_once('LSP Inlayhints attached failed: nil client.', vim.log.levels.ERROR)
    return
  end

  if not client.server_capabilities.inlayHintProvider then
    return
  end

  if M.state[bufnr] then
    return
  end

  M.state[bufnr] = client.id

  if client.name == 'zls' then
    vim.g.zig_fmt_autosave = 0
  end

  vim.lsp.inlay_hint.enable(true)
end

return M
