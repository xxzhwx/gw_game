
io.exists = function (path)
    local file = io.open(path, "r")
    if file then
        io.close(file)
        return true
    end
    return false
end

io.readfile = function (path)
    local file = io.open(path, "r")
    if file then
        local content = file:read("*a")
        io.close(file)
        return content
    end
    return nil
end

io.writefile = function (path, content, mode)
    mode = mode or "w+b"
    local file = io.open(path, mode)
    if file then
        if file:write(content) == nil then
            return false
        end
        io.close(file)
        return true
    end
    return false
end

io.filesize = function (path)
    local size = false
    local file = io.open(path, "r")
    if file then
        local current = file:seek()
        size = file:seek("end")
        file:seek("set", current)
        io.close(file)
    end
    return size
end

io.dirname = function (path)
    local pos = #path
    while pos > 0 do
        if path:byte(pos) == 47 then -- "/"
            break
        end
        pos = pos - 1
    end
    return path:sub(1, pos)
end

io.filename = function (path)
    local pos = #path
    while pos > 0 do
        if path:byte(pos) == 47 then -- "/"
            break
        end
        pos = pos - 1
    end
    return path:sub(pos + 1)
end

io.extname = function (path)
    for i = #path, 1, -1 do
        local b = path:byte(i)
        if b == 46 then -- "."
            return path:sub(i, #path)
        elseif b == 47 then -- "/"
            return
        end
    end
end

io.pathinfo = function (path)
    local pos = #path
    local extpos = pos + 1
    while pos > 0 do
        local b = path:byte(pos)
        if b == 46 then -- "."
            extpos = pos
        elseif b == 47 then -- "/"
            break
        end
        pos = pos - 1
    end
    local dirname = path:sub(1, pos)
    local filename = path:sub(pos + 1)
    extpos = extpos - pos
    local basename = filename:sub(1, extpos - 1)
    local extname = filename:sub(extpos)
    return {
        dirname = dirname,
        filename = filename,
        basename = basename,
        extname = extname,
    }
end
