local skynet = require "skynet"
require "skynet.manager"

local logpath = skynet.getenv("logpath") or "./log"
local logfilename = skynet.getenv("logfilename") or "skynet"
local is_daemon = skynet.getenv("daemon") ~= nil

local is_shutdown = false
local queue = {}
local log_file = {}

local LEVEL_DESC = {
    [1] = "[debug]",
    [2] = "[info ]",
    [3] = "[warn ]",
    [4] = "[error]",

    [5] = "" -- skynet.error
}

local LEVEL_COLOR = {
    [1] = "\x1b[36m", -- "\x1b[32m"
    [2] = "\x1b[34m",
    [3] = "\x1b[33m",
    [4] = "\x1b[31m",

    [5] = "\x1b[0m",
}

local CMD = {}

function CMD.log(source, level, str)
    local timestamp = math.floor(skynet.time())
    local date_desc = os.date("%Y%m%d", timestamp)
    local time_desc = os.date("[%Y-%m-%d %H:%M:%S]", timestamp)

    table.insert(queue, {
        source = source,
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

local function run_once_in_console_mode()
    for _, info in ipairs(queue) do
        print(string.format("%s[:%08x]%s%s %s%s",
            LEVEL_COLOR[info.level],
            info.source,
            info.time_desc,
            LEVEL_DESC[info.level],
            info.str,
            "\x1b[0m")
        )
    end

    if #queue > 0 then
        queue = {}
    end
end

local function run_once_in_daemon_mode()
    for _, info in ipairs(queue) do
        local filepath = string.format("%s/%s_%s.log", logpath, logfilename, info.date_desc)
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
            f:write(string.format("[:%08x]%s%s %s\n", info.source, info.time_desc, LEVEL_DESC[info.level], info.str))
        end
    end

    if #queue > 0 then
        queue = {}
    end

    local f = log_file[2]
    if f then
        f:flush()
    end

    if is_shutdown then
        close_log_file()
    end
end

local run_once = run_once_in_console_mode
if is_daemon then
    run_once = run_once_in_daemon_mode
end

local function run()
    while true do
        if not is_shutdown then
            run_once()
        end
        skynet.sleep(100)
    end
end

function CMD.shutdown()
    if is_shutdown then return end
    is_shutdown = true
    run_once()
end

skynet.register_protocol {
	name = "text",
	id = skynet.PTYPE_TEXT,
	unpack = skynet.tostring,
	dispatch = function(session, source, msg)
		CMD.log(source, 5, msg) -- 5 : skynet.error
	end
}

skynet.start(function ()
    os.execute("mkdir -p " .. logpath)

    skynet.register(".loggerd")
    skynet.dispatch("lua", function (session, source, cmd, ...)
        local f = assert(CMD[cmd], "unknown command: " .. cmd)
        if session > 0 then
            skynet.retpack(f(source, ...))
        else
            f(source, ...)
        end
    end)

    skynet.timeout(0, run)
end)