
string.startswith = function (s, prefix)
    if not s or not prefix then return false end

    if string.find(s, prefix, 1, true) == 1 then
        return true
    end
    return false
end

string.endswith = function (s, suffix)
    if not s or not suffix then return false end

    s = string.reverse(s)
    suffix = string.reverse(suffix)
    if string.find(s, suffix, 1, true) == 1 then
        return true
    end
    return false
end

string.isnumber = function (s)
    if not s then return false end

    local l = string.len(s)
    if l == 0 then
        return false
    end

    for i=1, l do
        local c = string.sub(s, i, i)
        if not (c >= '0' and c <= '9') then
            return false
        end
    end
    return true
end

string.isalpha = function (s)
    if not s then return false end

    local l = string.len(s)
    if l == 0 then
        return false
    end

    for i=1, l do
        local c = string.sub(s, i, i)
        if not ((c >= 'a' and c <= 'z') or (c >= 'A' and c <= 'Z')) then
            return false
        end
    end
    return true
end

local function urlencodechar(char)
    return "%" .. ("%02X"):format(char:byte())
end

string.urlencode = function (input)
    input = input:gsub("\n", "\r\n")
    input = input:gsub("([^%w%.%- ])", urlencodechar)
    return input:gsub(" ", "+")
end

string.urldecode = function (input)
    input = input:gsub("+", " ")
    input = input:gsub("%%(%x%x)", function (h)
        return string.char(tonumber(h, 16) or 0)
    end)
    input = input:gsub("\r\n", "\n")
end

string.split = function (input, sep)
    local parts = {}
    sep = sep and "([^"..sep.."]+)" or "([^\t]+)"
    input:gsub(sep, function (c)
        table.insert(parts, c)
    end)
    return parts
end
