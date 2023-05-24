local M = {}

M.servers_config = {
    jdtls = {
        hint_adapter = function(h)
            if not h.kind then
                h.kind = 2
            end
        end,
    },
    lua_ls = {
        hint_adapter = function(h)
            if h.kind == 1 then
                h.paddingRight = false
            elseif h.kind == 2 then
                h.paddingLeft = false
            end
        end,
    },
}

function M.adapt(result, client_name)
    result = result or {}
    for _, hint in ipairs(result) do
        if not hint then
            goto continue
        end

        local kind = hint.kind
        if type(kind) == 'string' then
            hint.kind = (kind:lower():match 'parameter' and 2) or 1
        end

        local s = M.servers_config[client_name]
        if s and s.hint_adapter then
            s.hint_adapter(hint)
        end
        ::continue::
    end
    return result
end

return M
