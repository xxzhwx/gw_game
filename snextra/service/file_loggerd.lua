local skynet = require "skynet"
require "skynet.manager"

local log_dir = skynet.getenv("log_dir")
local is_shutdown = false
local queues = {}

local function mkdir(path)
    if not os.rename(path, path) then
        os.execute("mkdir -p " .. path)
    end
end

local function get_time_str(str)
    return "[" .. os.date("%F %T", math.floor(skynet.time())) .. "]" .. str
end

local CMD = {}

function CMD.log(filepath, level, str)
    local queue = queues[filepath]
    if not queue then
        queue = {}
        queues[filepath] = queue
    end

    table.insert(queue, {level, get_time_str(str)})
end

local function run_once()
    local ok, err = xpcall(function ()
        for filepath, queue in pairs(queues) do
            --todo get dir and then mkdir
            local f = io.open(filepath)
            if f then
                for _, info in ipairs(queue) do
                    f:write(info[2])
                    f:write("\n")
                end
                f:close()
            end
            queues[filepath] = nil
        end
    end, debug.traceback)

    if not ok then
        skynet.error(err)
    end
end

local function run()
    while true do
        skynet.sleep(100 * 3)
        if is_shutdown then return end
        run_once()
    end
end

function CMD.shutdown()
    if is_shutdown then return end
    is_shutdown = true
    run_once()
end

skynet.start(function ()
    skynet.register(".file_loggerd")
    skynet.dispatch("lua", function (session, source, cmd, ...)
        local f = CMD[cmd]
        if session > 0 then
            skynet.retpack(f(...))
        else
            f(...)
        end
    end)

    skynet.timeout(0, run)
end)