local lua_unit = require "unittest.lua_unit"

local ut = {}
ut.Assert = lua_unit.Assert

function ut.gen_case(case_name, ...)
    local clazz = lua_unit.LuaUnit:derive(case_name)
    local supers = {...}
    if #supers > 0 then
        for _, super in ipairs(supers) do
            for k, v in pairs(super) do
                clazz[k] = v
            end
        end
    end
    return clazz
end

-- run all if group_name == nil
function ut.run_group(config, group_name)
    for _, conf in ipairs(config) do
        if not group_name or conf.group_name == group_name then

            for _, mod in ipairs(conf.cases) do
                local case = require(mod)
                if case then
                    case.run()
                end
            end
        end
    end
end

return ut
