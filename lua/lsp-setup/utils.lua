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

function M.default_mappings(bufnr, mappings)
    local defaults = {
        gD = vim.lsp.buf.declaration,
        gd = vim.lsp.buf.definition,
        gi = vim.lsp.buf.implementation,
        gr = vim.lsp.buf.references,
        K = vim.lsp.buf.hover,
        ['<C-k>'] = vim.lsp.buf.signature_help,
        ['<space>rn'] = vim.lsp.buf.rename,
        ['<space>ca'] = vim.lsp.buf.code_action,
        ['<space>f'] = vim.lsp.buf.formatting, -- compatible with nvim-0.7
        ['<space>e'] = vim.diagnostic.open_float,
        ['[d'] = vim.diagnostic.goto_prev,
        [']d'] = vim.diagnostic.goto_next,
    }
    mappings = vim.tbl_deep_extend('keep', mappings or {}, defaults)
    M.mappings(bufnr, mappings)
end

function M.disable_formatting(client)
    if vim.fn.has('nvim-0.8') == 1 then
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
    else
        client.server_capabilities.document_formatting = false
        client.server_capabilities.document_range_formatting = false
    end
end

function M.format_on_save(client)
    if client.supports_method('textDocument/formatting') then
        local lsp_format_augroup = vim.api.nvim_create_augroup('LspFormat', { clear = true })
        vim.api.nvim_create_autocmd('BufWritePre', {
            group = lsp_format_augroup,
            callback = function()
                if vim.fn.has('nvim-0.8') == 1 then
                    vim.lsp.buf.format()
                else
                    vim.lsp.buf.formatting_sync({}, 1000)
                end
            end,
        })
    end
end

return M
