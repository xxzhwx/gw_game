
string.startswith = function (s, prefix)
    local i = string.find(s, prefix, 1, true)
    return (i and i == 1)
end

string.endswith = function (s, suffix)
end