local utils = require('lsp-setup.utils')
local inlay_hints = require('lsp-setup.inlay_hints')

local function lsp_servers(opts)
    local servers = {}
    for server, config in pairs(opts.servers) do
        local server_name, _ = utils.parse_server(server)

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
    if vim.fn.has('nvim-0.8') ~= 1 then
        vim.notify_once('LSP setup requires Neovim 0.8.0+', vim.log.levels.ERROR)
        return
    end

    opts = vim.tbl_deep_extend('keep', opts, {
        default_mappings = true,
        mappings = {},
        servers = {},
        inlay_hints = inlay_hints.opts,
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
        })
        mason_lspconfig.setup_handlers({
            function(server_name)
                local config = servers[server_name] or nil
                if config == nil then
                    return
                end
                require('lspconfig')[server_name].setup(config)
            end
        })
        return
    else
        for server_name, config in pairs(servers) do
            require('lspconfig')[server_name].setup(config)
        end
    end
end

return M
