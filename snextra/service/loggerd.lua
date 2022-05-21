local skynet = require "skynet"
require "skynet.manager"

local log_dir = skynet.getenv("log_dir") or "./log"
local log_filename = skynet.getenv("log_filename") or "default"

local is_shutdown = false
local queue = {}
local log_file = {}

local LEVEL_DESC = {
    [1] = "[debug]",
    [2] = "[info ]",
    [3] = "[warn ]",
    [4] = "[error]",
}

local CMD = {}

function CMD.log(level, str)
    local timestamp = math.floor(skynet.time())
    local date_desc = os.date("%Y%m%d", timestamp)
    local time_desc = os.date("[%Y-%m-%d %H:%M:%S]", timestamp)

    table.insert(queue, {
        level = level,
        str = str,
        date_desc = date_desc,
        time_desc = time_desc,
    })
end

local function close_log_file()
    if log_file[2] then
        log_file[2]:close()
        log_file[2] = nil

        log_file[1] = nil
    end
end

local function run_once()
    local ok, err = xpcall(function ()
        for _, info in ipairs(queue) do
            local filepath = string.format("%s/%s_%s.log", log_dir, log_filename, info.date_desc)
            if filepath ~= log_file[1] then
                close_log_file()

                local f = io.open(filepath, "a+")
                if f then
                    log_file[1] = filepath
                    log_file[2] = f
                end
            end

            local f = log_file[2]
            if f then
                f:write(string.format("%s%s %s\n", LEVEL_DESC[info.level], info.time_desc, info.str))
            end
        end

        queue = {}
    end, debug.traceback)

    if not ok then
        skynet.error(err)
    end

    if log_file[2] then
        log_file[2]:flush()
    end

    if is_shutdown then
        close_log_file()
    end
end

local function run()
    while true do
        skynet.sleep(300)
        if not is_shutdown then
            run_once()
        end
    end
end

function CMD.shutdown()
    if is_shutdown then return end
    is_shutdown = true
    run_once()
end

skynet.start(function ()
    os.execute("mkdir -p " .. log_dir)

    skynet.register(".loggerd")
    skynet.dispatch("lua", function (session, source, cmd, ...)
        local f = assert(CMD[cmd], "unknown command: " .. cmd)
        if session > 0 then
            skynet.retpack(f(...))
        else
            f(...)
        end
    end)

    skynet.timeout(0, run)
end)