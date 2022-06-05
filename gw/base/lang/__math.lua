
math.clamp = function (value, min, max)
    assert(min <= max)

    if value < min then
        value = min
    end
    if value > max then
        value = max
    end
    return value
end