local _ = require('mason-core.functional')
local utils = require('lsp-setup.utils')

local function lsp_servers(opts)
    local servers = {}
    for server, config in pairs(opts.servers) do
        local server_name, _ = require('mason-core.package').Parse(server)

        config = vim.tbl_deep_extend('keep', config, {
            on_attach = opts.on_attach,
            capabilities = opts.capabilities,
            settings = {},
        })

        local ok, cmp = pcall(require, 'cmp_nvim_lsp')
        if ok then
            config.capabilities = cmp.default_capabilities(config.capabilities)
        end
        local ok, coq = pcall(require, 'coq')
        if ok then
            config = coq.lsp_ensure_capabilities(config)
        end

        servers[server_name] = config
    end

    return servers
end

local defaults = {
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
    ['[d'] = vim.diagnostic.goto_prev,
    [']d'] = vim.diagnostic.goto_next,
}

local M = {}

function M.setup(opts)
    opts = vim.tbl_deep_extend('keep', opts, {
        default_mappings = true,
        mappings = {},
        servers = {},
        capabilities = vim.lsp.protocol.make_client_capabilities(),
        ---@diagnostic disable-next-line: unused-local
        on_attach = function(client, bufnr)
            utils.format_on_save(client)
        end,
    })

    vim.api.nvim_create_augroup('LspSetup', {})
    vim.api.nvim_create_autocmd('LspAttach', {
        group = 'LspSetup',
        callback = function(args)
            local bufnr = args.buf
            local mappings = opts.mappings
            if opts.default_mappings then
                mappings = vim.tbl_deep_extend('keep', mappings or {}, defaults)
            end
            utils.mappings(bufnr, mappings)
        end
    })

    local servers = lsp_servers(opts)

    if vim.api.nvim_get_commands({})['Mason'] == nil then
        require('mason').setup()
    end
    require('mason-lspconfig').setup({
        ensure_installed = _.keys(opts.servers),
    })
    require('mason-lspconfig').setup_handlers({
        function(server_name)
            local config = servers[server_name] or nil
            if config == nil then
                return
            end
            require('lspconfig')[server_name].setup(config)
        end
    })
end

return M
