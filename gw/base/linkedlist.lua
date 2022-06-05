
local setmetatable = setmetatable

local linkedlist = {}
linkedlist.__index = linkedlist

function linkedlist.new()
    local t = {length = 0, first = nil, last = nil,}
    return setmetatable(t, linkedlist)
end

function linkedlist:clear()
    self.last = nil
    self.first = nil
    self.length = 0
end

function linkedlist:push(value)
    self:insert(value)
end

function linkedlist:pop()
    if not self.last then return end

    local node = self.last
    self:remove(node)
    return node._value
end

function linkedlist:insert(value, iter)
    local node = {
        _value = value,
        _prev = nil,
        _next = nil,
        _removed = true,
    }
    self:insert_node(value, iter)
end

function linkedlist:erase(value, all, iter)
    iter = iter or self.first

    while iter ~= nil do
        if iter._value == value then
            self:remove(iter)

            if not all then
                break
            end
        end

        iter = iter._next
    end
end

function linkedlist:insert_node(node, after)
    assert(node._removed)

    after = after or self.last

    if after then
        if after._next then
            after._next._prev = node
            node._next = after._next
        else
            self.last = node
        end

        node._prev = after
        after._next = node
    else
        assert(self.first == nil)
        self.first = node
        self.last = node
    end

    node._removed = false

    self.length = self.length + 1
end

function linkedlist:remove(node)
    if node._removed then return end

    if node._next then
        if node._prev then
            node._next._prev = node._prev
            node._prev._next = node._next
        else
            -- this was the first node
            node._next._prev = nil
            self.first = node._next
        end
    else
        if node._prev then
            -- this was the last node
            node._prev._next = nil
            self.last = node._prev
        else
            -- this was the only node
            assert(self.first == node and self.last == node)
            self.first = nil
            self.last = nil
        end
    end

    -- we do NOT remove _prev and _next
    -- to support removing node while iterating

    -- node._prev = nil
    -- node._next = nil
    node._removed = true

    self.length = self.length - 1
end

local function iterate(self, current)
    if not current then
        current = self.first
    else
        current = current._next
    end

    if not current then
        return nil
    end

    return current, current._value
end

function linkedlist:iterate()
    return iterate, self, nil
end

local function reverse_iterate(self, current)
    if not current then
        current = self.last
    else
        current = current._prev
    end

    if not current then
        return nil
    end

    return current, current._value
end

function linkedlist:reverse_iterate()
    return reverse_iterate, self, nil
end

--- Usage:
-- local l = linkedlist.new()
-- for i = 1, 5 do
--     l:push(i)
-- end

-- for iter, v in l:iterate() do
--     print(v)
--     l:remove(iter)
-- end

return linkedlist
