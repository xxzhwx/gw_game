local table_insert = table.insert

table.BLANK = {}

setmetatable(table.BLANK, {
    __index = function (_, k) error("Attempt to read undeclared variable: "..k) end,
    __newindex = function (_, k) error("Attempt to write undeclared variable: "..k) end,
})

table.empty = function (t)
    if not t then return true end
    if next(t) then
        return false
    end
    return true
end

table.count = function (t)
    if not t then return 0 end

    local c = 0
    for _,_ in pairs(t) do
        c = c + 1
    end
    return c
end

table.contains = function (t, value)
    if not t then return false end
    for _,v in pairs(t) do
        if v == value then
            return true
        end
    end
    return false
end

table.contains_key = function (t, key)
    if not t then return false end
    for k,_ in pairs(t) do
        if k == key then
            return true
        end
    end
    return false
end

table.keys = function (t)
    local ret = {}
    for k,_ in pairs(t) do
        table_insert(ret, k)
    end
    return ret
end

table.update = function (dest, src)
    assert(type(dest)=="table" and type(src)=="table")
    for k,v in pairs(src) do
        dest[k] = v
    end
end

table.map = function (t, proc, ...)
    local ret = {}
    for k, v in pairs(t) do
        ret[k] = proc(k, v, ...)
    end
    return ret
end

table.each = function (t, proc, ...)
    for k, v in pairs(t) do
        if proc(k, v, ...) then
            break
        end
    end
end

table.copy = function (t)
    if not t then return nil end

    local ret = {}
    for k,v in pairs(t) do
        ret[k] = v
    end
    return setmetatable(ret, getmetatable(t))
end

table.deepcopy = function (t)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local newtb = {}
        lookup_table[object] = newtb
        for k,v in pairs(object) do
            newtb[_copy(k)] = _copy(v)
        end
        return setmetatable(newtb, getmetatable(object))
    end
    return _copy(t)
end

local _MAX_DEPTH = 16

local function _indentBy(n)
    return string.rep(" ", n)
end

local function _toTreeString(t, depth)
    if type(t) ~= "table" then
        return tostring(t)
    end

    local indent = _indentBy(depth)
    local result = indent .. "{\n"

    if depth > _MAX_DEPTH then
        result = result .. "...\n"
        return result .. indent .. "}"
    end

    for k, v in pairs(t) do
        result = result .. _indentBy(depth + 1)
        if type(k) == "string" then
            result = result .. "[" .. string.format('%q', k) .. "]="
        else
            result = result .. "[" .. tostring(k) .. "]="
        end
        if type(v) == "table" then
            local sub = _toTreeString(v, depth + 2)
            result = result .. "\n" .. sub .. ",\n"
        else
            if type(v) == "string" then
                result = result .. string.format('%q', v) .. ",\n"
            else
                result = result .. tostring(v) .. ",\n"
            end
        end
    end
    return result .. indent .. "}"
end

table.tostring = function (t)
    return _toTreeString(t, 0)
end