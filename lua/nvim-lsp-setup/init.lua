local _ = require('mason-core.functional')
local utils = require('nvim-lsp-setup.utils')

local M = {}

function M.setup(opts)
    opts = vim.tbl_deep_extend('keep', opts, {
        default_mappings = true,
        mappings = {},
        servers = {},
        capabilities = vim.lsp.protocol.make_client_capabilities(),
    })
    local servers = opts.servers
    local mappings = opts.mappings

    setmetatable(servers, {
        __index = function()
            return {}
        end,
    })

    if vim.api.nvim_get_commands({})['Mason'] == nil then
        require('mason').setup({})
    end
    require('mason-lspconfig').setup({
        ensure_installed = _.keys(servers),
    })

    for server, config in pairs(servers) do
        local server_name, _ = require('mason-core.package').Parse(server)

        config = vim.tbl_deep_extend('keep', config, {
            on_attach = function(client, bufnr)
                if opts.on_attach then
                    opts.on_attach(client, bufnr)
                else
                    utils.format_on_save(client)
                end
            end,
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
                utils.default_mappings(bufnr, mappings)
            else
                utils.mappings(bufnr, mappings)
            end

            on_attach(client, bufnr)
        end

        require('lspconfig')[server_name].setup(config)
    end
end

return M
