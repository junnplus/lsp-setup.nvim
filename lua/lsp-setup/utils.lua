local M = {}

function M.mappings(bufnr, mappings)
    local opts = { noremap = true, silent = true, buffer = bufnr }
    for key, cmd in pairs(mappings or {}) do
        if type(cmd) == 'string' and cmd:find('^lua') ~= nil then
            cmd = ':' .. cmd .. '<cr>'
        end
        vim.keymap.set('n', key, cmd, opts)
    end
end

function M.disable_formatting(client)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
end

function M.format_on_save(client)
    if client.supports_method('textDocument/formatting') then
        local lsp_format_augroup = vim.api.nvim_create_augroup('LspFormat', { clear = true })
        vim.api.nvim_create_autocmd('BufWritePre', {
            group = lsp_format_augroup,
            callback = function()
                vim.lsp.buf.format({ async = true })
            end,
        })
    end
end

-- @param server string
-- @return string, string
function M.parse_server(server)
    return unpack(vim.split(server, '@'))
end

-- @param t table
-- @return table
function M.get_keys(t)
    local keys = {}
    for key, _ in pairs(t) do
        table.insert(keys, key)
    end
    return keys
end

return M
