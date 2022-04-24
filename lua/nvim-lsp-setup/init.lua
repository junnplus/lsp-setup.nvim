local utils = require('nvim-lsp-setup.utils')

local M = {}

function M.setup(opts)
    opts = vim.tbl_deep_extend('keep', opts, {
        default_mappings = true,
        mappings = {},
        servers = {},
    })
    local servers = opts.servers
    local mappings = opts.mappings

    setmetatable(servers, {
        __index = function()
            return {}
        end,
    })

    utils.lsp_installer(servers).on_server_ready(function(server)
        local config = vim.tbl_deep_extend('keep', servers[server.name], {
            on_attach = function(client, bufnr)
                if opts.on_attach then
                    opts.on_attach(client, bufnr)
                else
                    utils.format_on_save(client)
                end
            end,
            capabilities = utils.capabilities(),
            settings = {},
            flags = {
                -- This will be the default in neovim 0.7+
                debounce_text_changes = 150,
            },
        })
        local on_attach = config.on_attach
        config.on_attach = function(client, bufnr)
            if opts.default_mappings then
                utils.default_mappings(bufnr, mappings)
            else
                utils.mappings(bufnr, mappings)
            end

            on_attach(client, bufnr)
        end
        server:setup(config)
    end)
end

return M
