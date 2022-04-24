local utils = require('nvim-lsp-setup.utils')

local M = {}

function M.setup(opts)
    local servers = opts.servers
    setmetatable(servers, {
        __index = function()
            return {
                on_attach = function(client, bufnr)
                    utils.mappings(bufnr)
                    utils.format_on_save(client)
                end,
                capabilities = utils.capabilities(),
                settings = {},
                flags = {
                    debounce_text_changes = 150,
                },
            }
        end,
    })
    utils.lsp_installer(servers).on_server_ready(function(server)
        local config = servers[server.name]
        server:setup(config)
    end)
end

return M
