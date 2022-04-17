local M = {}

local listeners_map = {} -- { [evt_name] = {{listener, filter}, }, }

local function get_or_new_listeners(evt_name)
    if not listeners_map[evt_name] then
        listeners_map[evt_name] = {}
    end
    return listeners_map[evt_name]
end

function M.add_listener(evt_name, func, filter)
    local listeners = get_or_new_listeners(evt_name)
    for _, v in ipairs(listeners) do
        if v[1] == func then
            error("do NOT add the listener repeatedly")
            return
        end
    end

    table.insert(listeners, {func, filter})
end

function M.remove_listener(evt_name, func)
    local listeners = listeners_map[evt_name]
    if not listeners then return end

    for i, v in ipairs(listeners) do
        if v[1] == func then
            table.remove(listeners, i)
            break
        end
    end
end

function M.dispatch(evt_name, ...)
    local listeners = listeners_map[evt_name]
    if not listeners then return end

    for _, v in ipairs(listeners) do
        if not v[2] or v[2](...) then
            v[1](...)
        end
    end
end

return M