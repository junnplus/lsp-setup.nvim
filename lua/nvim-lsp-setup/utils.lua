local M = {}

function M.lsp_installer(servers)
    local lsp_installer = require('nvim-lsp-installer')
    for name, _ in pairs(servers) do
        local found, server = lsp_installer.get_server(name)
        if found and not server:is_installed() then
            server:install()
        end
    end
    return lsp_installer
end

function M.capabilities()
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    local ok, cmp = pcall(require, 'cmp_nvim_lsp')
    if ok then
        return cmp.update_capabilities(capabilities)
    end
    return capabilities
end

function M.disable_formatting(client)
    client.resolved_capabilities.document_formatting = false
    client.resolved_capabilities.document_range_formatting = false
end

function M.mappings(bufnr, mappings)
    local function buf_set_keymap(...)
        vim.api.nvim_buf_set_keymap(bufnr, ...)
    end
    local opts = { noremap = true, silent = true }
    for key, cmd in pairs(mappings or {}) do
        buf_set_keymap('n', key, '<cmd>' .. cmd .. '<CR>', opts)
    end
end

function M.default_mappings(bufnr, mappings)
    local defaults = {
        gD = 'lua vim.lsp.buf.declaration()',
        gd = 'lua vim.lsp.buf.definition()',
        gt = 'lua vim.lsp.buf.type_definition()',
        gi = 'lua vim.lsp.buf.implementation()',
        gr = 'lua vim.lsp.buf.references()',
        K = 'lua vim.lsp.buf.hover()',
        ['<C-k>'] = 'lua vim.lsp.buf.signature_help()',
        ['<space>rn'] = 'lua vim.lsp.buf.rename()',
        ['<space>ca'] = 'lua vim.lsp.buf.code_action()',
        ['<space>f'] = 'lua vim.lsp.buf.formatting()',
        ['<space>e'] = 'lua vim.lsp.diagnostic.show_line_diagnostics()',
        ['[d'] = 'lua vim.lsp.diagnostic.goto_prev()',
        [']d'] = 'lua vim.lsp.diagnostic.goto_next()',
    }
    mappings = vim.tbl_deep_extend('keep', mappings or {}, defaults)
    M.mappings(bufnr, mappings)
end

function M.format_on_save(client)
    if client.resolved_capabilities.document_formatting then
        vim.cmd([[
          augroup Format
            au! * <buffer>
            au BufWritePre <buffer> lua vim.lsp.buf.formatting_sync(nil, 1000)
          augroup END
        ]])

        -- nvim 0.7+
        -- local lsp_format_augroup = 'lsp_format_augroup'
        -- vim.api.nvim_create_augroup(lsp_format_augroup, { clear = true })
        -- vim.api.nvim_create_autocmd('BufWritePre', {
        --     group = lsp_format_augroup,
        --     callback = function()
        --         vim.lsp.buf.formatting_sync(nil, 1000)
        --     end,
        -- })
    end
end

return M
