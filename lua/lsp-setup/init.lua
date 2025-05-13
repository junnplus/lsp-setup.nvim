local utils = require('lsp-setup.utils')
local inlay_hints = require('lsp-setup.inlay_hints')

---@param opts LspSetup.Options
---@return table<string, LspSetup.ServerConfig>
local function lsp_servers(opts)
  local servers = {}
  for server, config in pairs(opts.servers) do
    local server_name, _ = utils.parse_server(server)

    if type(config) == 'function' then
      config = config()
    end

    if type(config) == 'table' then
      config = vim.tbl_deep_extend('keep', config, {
        on_attach = opts.on_attach,
        capabilities = opts.capabilities,
        settings = {},
      })

      local ok1, cmp = pcall(require, 'cmp_nvim_lsp')
      if ok1 then
        config.capabilities = cmp.default_capabilities(config.capabilities)
      end
      local ok2, coq = pcall(require, 'coq')
      if ok2 then
        config = coq.lsp_ensure_capabilities(config)
      end
      local ok3, blink_cmp = pcall(require, 'blink.cmp')
      if ok3 then
        config.capabilities = blink_cmp.get_lsp_capabilities(opts.capabilities)
      end
      -- if opts.inlay_hints.enabled == true then
      --     config.capabilities.textDocument = {
      --         inlayHint = {
      --             dynamicRegistration = false,
      --             resolveSupport = {
      --                 properties = {},
      --             },
      --         },
      --     }
      -- end
    end

    servers[server_name] = config
  end

  return servers
end

local default_mappings = {
  gD = vim.lsp.buf.declaration,
  gd = vim.lsp.buf.definition,
  gi = vim.lsp.buf.implementation,
  gr = vim.lsp.buf.references,
  K = vim.lsp.buf.hover,
  ['<C-k>'] = vim.lsp.buf.signature_help,
  ['<space>rn'] = vim.lsp.buf.rename,
  ['<space>ca'] = vim.lsp.buf.code_action,
  ['<space>f'] = vim.lsp.buf.formatting,
  ['<space>e'] = vim.diagnostic.open_float,
  ['[d'] = function() vim.diagnostic.jump({ count = -1, float = true }) end,
  [']d'] = function() vim.diagnostic.jump({ count = 1, float = true }) end,
}

local M = {}

---@class LspSetup.ServerConfig : vim.lsp.ClientConfig
---@field cmd? string[]|fun(dispatchers: vim.lsp.rpc.Dispatchers): vim.lsp.rpc.PublicClient

---@class LspSetup.Options
---Enable default key mappings.
---@field default_mappings? boolean
---Custom key mappings for LSP.
---@field mappings? table<string, string|function>
---Defines the capabilities provided by the client.
---@field capabilities? lsp.ClientCapabilities
---Callback invoked when client attaches to a buffer.
---@field on_attach? fun(client: vim.lsp.Client, bufnr: number)
---Configurations for LSP servers.
---@field servers table<string, LspSetup.ServerConfig|function>
---Configurations for inlay hints.
---@field inlay_hints? InlayHints.Options
M.defaults = {
  default_mappings = true,
  mappings = {},
  capabilities = vim.lsp.protocol.make_client_capabilities(),
  on_attach = function(client, _)
    utils.format_on_save(client)
  end,
  servers = {},
  inlay_hints = inlay_hints.opts,
}

---@param opts LspSetup.Options
---@return nil
function M.setup(opts)
  if vim.fn.has('nvim-0.11') ~= 1 then
    vim.notify_once('LSP setup requires Neovim 0.11.0+', vim.log.levels.ERROR)
    return
  end

  opts = vim.tbl_deep_extend('keep', opts, M.defaults)

  vim.api.nvim_create_augroup('LspSetup', {})
  vim.api.nvim_create_autocmd('LspAttach', {
    group = 'LspSetup',
    callback = function(args)
      local bufnr = args.buf
      local mappings = opts.mappings
      if opts.default_mappings then
        mappings = vim.tbl_deep_extend('keep', mappings or {}, default_mappings)
      end
      utils.mappings(bufnr, mappings)
    end
  })

  inlay_hints.setup(opts.inlay_hints)
  local servers = lsp_servers(opts)

  local ok1, mason = pcall(require, 'mason')
  local ok2, mason_lspconfig = pcall(require, 'mason-lspconfig')
  if ok1 and ok2 then
    if vim.api.nvim_get_commands({})['Mason'] == nil then
      mason.setup()
    end
    mason_lspconfig.setup({
      ensure_installed = utils.get_keys(opts.servers),
      automatic_enable = false,
    })
  end

  for server_name, config in pairs(servers) do
    local ok, lsp_config = pcall(require, ('mason-lspconfig.lsp.%s'):format(server_name))
    if ok then
      config = vim.tbl_deep_extend('keep', config, lsp_config)
    end
    vim.lsp.config(server_name, config)
    vim.lsp.enable(server_name)
  end
end

return M
