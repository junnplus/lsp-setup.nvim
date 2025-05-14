local M = {}

---@param bufnr number
---@param mappings table<string, string|function|{ cmd: string|function, opts: vim.keymap.set.Opts? }>
function M.mappings(bufnr, mappings)
  ---@type vim.keymap.set.Opts
  local _opts = { noremap = true, silent = true, buffer = bufnr }
  for key, mapping in pairs(mappings or {}) do
    ---@type string|function
    local cmd = nil
    ---@type vim.keymap.set.Opts
    local opts = nil
    if type(mapping) == 'table' then
      cmd = mapping.cmd
      opts = vim.tbl_deep_extend('force', _opts, mapping.opts or {})
    else
      cmd = mapping
      opts = _opts
    end
    if type(cmd) == 'string' and cmd:find('^lua') ~= nil then
      cmd = ':' .. cmd .. '<cr>'
    end
    vim.keymap.set('n', key, cmd, opts)
  end
end

---@param client vim.lsp.Client
function M.disable_formatting(client)
  client.server_capabilities.documentFormattingProvider = false
  client.server_capabilities.documentRangeFormattingProvider = false
end

---@param client vim.lsp.Client
function M.format_on_save(client)
  if client:supports_method('textDocument/formatting') then
    local lsp_format_augroup = vim.api.nvim_create_augroup('LspFormat', { clear = true })
    vim.api.nvim_create_autocmd('BufWritePre', {
      group = lsp_format_augroup,
      callback = function()
        vim.lsp.buf.format()
      end,
    })
  end
end

---@param server string
function M.parse_server(server)
  return unpack(vim.split(server, '@'))
end

---@param t table
---@return table
function M.get_keys(t)
  local keys = {}
  for key, _ in pairs(t) do
    table.insert(keys, key)
  end
  return keys
end

return M
