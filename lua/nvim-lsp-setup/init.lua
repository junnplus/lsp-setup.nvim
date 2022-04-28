local utils = require('nvim-lsp-setup.utils')
local notify = require('nvim-lsp-installer.notify')

local M = {}

function M.setup(opts)
    opts = vim.tbl_deep_extend('keep', opts, {
        installer = {},
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

    local lsp_installer = require('nvim-lsp-installer')
    assert(lsp_installer.setup, 'Please upgrade nvim-lsp-installer')

    if require('nvim-lsp-installer.settings').uses_new_setup == false then
        lsp_installer.setup(opts.installer)
    end

    for server_name, config in pairs(servers) do
        local candidates = {}
        local found, server = lsp_installer.get_server(server_name)
        if found and not server:is_installed() then
            table.insert(candidates, server_name)
            server:install()
        end
        if #candidates > 0 then
            notify('Installing LSP servers: ' .. table.concat(candidates, ', '))
        end

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
            flags = {
                -- This will be the default in neovim 0.7+
                debounce_text_changes = 150,
            },
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
