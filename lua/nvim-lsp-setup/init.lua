local _ = require('mason-core.functional')
local utils = require('nvim-lsp-setup.utils')

local function lsp_servers(opts)
    local servers = {}
    for server, config in pairs(opts.servers) do
        local server_name, _ = require('mason-core.package').Parse(server)

        config = vim.tbl_deep_extend('keep', config, {
            on_attach = opts.on_attach,
            capabilities = opts.capabilities,
            settings = {},
        })

        local capabilities = config.capabilities
        local ok, cmp = pcall(require, 'cmp_nvim_lsp')
        if ok then
            config.capabilities = cmp.update_capabilities(capabilities)
        end

        local on_attach = config.on_attach
        config.on_attach = function(client, bufnr)
            if opts.default_mappings then
                utils.default_mappings(bufnr, opts.mappings)
            else
                utils.mappings(bufnr, opts.mappings)
            end

            on_attach(client, bufnr)
        end

        servers[server_name] = config
    end

    return servers
end

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

    local servers = lsp_servers(opts)

    if vim.api.nvim_get_commands({})['Mason'] == nil then
        require('mason').setup()
    end
    require('mason-lspconfig').setup_handlers({
        function(server_name)
            local config = servers[server_name] or {}
            require('lspconfig')[server_name].setup(config)
        end
    })
    require('mason-lspconfig').setup({
        ensure_installed = _.keys(opts.servers),
    })
end

return M
