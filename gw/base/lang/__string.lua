
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

string.escape = function (s)
    s = string.gsub(s, "([$=+%c])", function (c)
        return string.format("%%%02X", string.byte(c))
    end)

    return string.gsub(s, " ", "+")
end

string.unescape = function (s)
    s = string.gsub(s, "+", " ")

    return string.gsub(s, "%%(%x%x)", function (h)
        return string.char(tonumber(h, 16))
    end)
end