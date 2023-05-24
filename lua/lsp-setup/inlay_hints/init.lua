local adapter = require('lsp-setup.inlay_hints.adapter')

local ns = vim.api.nvim_create_namespace('textDocument/inlayHints')

local M = {}

M.opts = {
    enabled = false,
    parameter_hints = true,
    type_hints = true,
    highlight = 'Comment',
    priority = 0,
}
M.state = setmetatable({}, { __index = nil })

function M.setup(opts)
    M.opts = vim.tbl_deep_extend('keep', opts, M.opts)
    if not opts.enabled then
        return
    end

    if vim.fn.has('nvim-0.10') ~= 1 then
        vim.notify_once('LSP Inlayhints requires Neovim 0.10.0+', vim.log.levels.ERROR)
        return
    end

    vim.api.nvim_create_augroup('LspSetup_Inlayhints', {})
    vim.api.nvim_create_autocmd('LspAttach', {
        group = 'LspSetup_Inlayhints',
        callback = function(args)
            if not (args.data and args.data.client_id) then
                return
            end

            local bufnr = args.buf
            local client = vim.lsp.get_client_by_id(args.data.client_id)
            M.on_attach(client, bufnr)
        end,
    })
end

function M.on_attach(client, bufnr)
    if not client then
        vim.notify_once('LSP Inlayhints attach to a nil client.', vim.log.levels.ERROR)
        return
    end
    if client.server_capabilities.inlayHintProvider == nil then
        return
    end

    if M.state[bufnr] then
        return
    end

    M.state[bufnr] = client.id

    M.render(bufnr, true)
    vim.api.nvim_create_autocmd('User', {
        pattern = { 'LspProgressUpdate' },
        group = 'LspSetup_Inlayhints',
        callback = function()
            local msgs = vim.lsp.util.get_progress_messages()
            for _, msg in ipairs(msgs) do
                if msg.done then
                    M.render(bufnr, true)
                end
                return
            end
        end,
    })
    vim.api.nvim_buf_attach(bufnr, false, {
        on_lines = function()
            M.render(bufnr, false)
        end
    })
end

local function line_col(row, offset_encoding)
    local line = vim.api.nvim_buf_get_lines(0, row - 1, row, true)[1]
    if not line or #line == 0 then
        return 0
    end

    return vim.lsp.util._str_utfindex_enc(line, nil, offset_encoding)
end

local function hint_ranges(offset_encoding, full)
    local start_line = 1
    local end_line = vim.api.nvim_buf_line_count(0)

    if not full then
        start_line = math.max(start_line, vim.fn.line('w0') - 50)
        end_line = math.min(end_line, vim.fn.line('w$') + 50)
    end

    return {
        start = { start_line, 0 },
        _end = { end_line, line_col(end_line, offset_encoding) },
    }
end

local function make_label(hint, opts)
    local label = ''
    if hint.kind == 1 and not opts.type_hints then
        return label
    elseif hint.kind == 2 and not opts.parameter_hints then
        return label
    end

    if type(hint.label) == 'table' then
        local parts = {}
        for _, label_part in ipairs(hint.label) do
            parts[#parts + 1] = label_part.value
        end
        label = table.concat(parts)
    else
        label = hint.label
    end

    return label
end

local function make_virt_text(label, hint, opts)
    local tbl = {}
    tbl[#tbl + 1] = hint.paddingLeft and { ' ', opts.highlight } or nil
    tbl[#tbl + 1] = { label, opts.highlight }
    tbl[#tbl + 1] = hint.paddingRight and { ' ', opts.highlight } or nil
    return tbl
end

local function on_render(err, result, ctx, opts, range)
    local bufnr = ctx.bufnr
    M.clear(bufnr, range.start[1] - 1, range._end[1])

    if err then
        return
    end

    local client = vim.lsp.get_client_by_id(ctx.client_id)
    if not client then
        return
    end

    local hints = adapter.adapt(result, client.name) or {}
    for _, hint in pairs(hints) do
        local line, col = hint.position.line, hint.position.character
        if not (line >= range.start[1] - 1 and line <= range._end[1]) then
            goto continue
        end

        local label = make_label(hint, opts)
        if not label or label == '' then
            goto continue
        end

        local virt_text = make_virt_text(label, hint, opts)
        if not virt_text then
            goto continue
        end

        vim.api.nvim_buf_set_extmark(bufnr, ns, line, col, {
            virt_text = virt_text,
            virt_text_pos = 'inline',
            strict = false,
            priority = opts.priority,
        })
        ::continue::
    end
end

function M.clear(bufnr, line_start, line_end)
    if bufnr == nil or bufnr == 0 then
        bufnr = vim.api.nvim_get_current_buf()
    end
    if not M.state[bufnr] then
        return
    end
    vim.api.nvim_buf_clear_namespace(bufnr, ns, line_start or 0, line_end or -1)
end

function M.render(bufnr, full)
    if bufnr == nil or bufnr == 0 then
        bufnr = vim.api.nvim_get_current_buf()
    end

    if not M.state[bufnr] then
        return
    end

    local client = vim.lsp.get_client_by_id(M.state[bufnr])
    if not client then
        return
    end

    local range = hint_ranges(client.offset_encoding, full)
    local params = {
        textDocument = vim.lsp.util.make_text_document_params(bufnr),
        range = {
            start = { line = range.start[1] - 1, character = range.start[2] },
            ['end'] = { line = range._end[1] - 1, character = range._end[2] },
        },
    }
    local handler = function(err, result, ctx)
        on_render(err, result, ctx, M.opts, range)
    end
    client.request('textDocument/inlayHint', params, handler, bufnr)
end

return M
