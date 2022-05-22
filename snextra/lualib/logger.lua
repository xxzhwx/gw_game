local skynet = require "skynet"

local is_user_logger = skynet.getenv("logger") ~= nil

local logger = {}

local LOG_LEVEL = {
    debug = 1,
    info = 2,
    warn = 3,
    error = 4,
}

local function init_log_level()
    if not logger.level then
        local name = skynet.getenv("loglevel")
        if not name or not LOG_LEVEL[name] then
            name = "debug"
        end

        logger.level = LOG_LEVEL[name]
    end
end

function logger.set_log_level(name)
    local level = LOG_LEVEL[name]
    if level then
        logger.level = level
    end
end

local function log(level, format, ...)
    local str = string.format(format, ...)
    if level >= LOG_LEVEL.warn then
        local info = debug.getinfo(3)
        if info then
            local filename = string.match(info.short_src, "[^/.]+.lua")
            str = string.format("%s  <%s:%d>", str, filename, info.currentline)
        end
    end

    if is_user_logger then
        skynet.send(".logger", "lua", "log", level, str)
    else
        skynet.error(str)
    end
end

function logger.debug(format, ...)
    if logger.level <= LOG_LEVEL.debug then
        log(LOG_LEVEL.debug, format, ...)
    end
end

function logger.info(format, ...)
    if logger.level <= LOG_LEVEL.info then
        log(LOG_LEVEL.info, format, ...)
    end
end

function logger.warn(format, ...)
    if logger.level <= LOG_LEVEL.warn then
        log(LOG_LEVEL.warn, format, ...)
    end
end

function logger.error(format, ...)
    if logger.level <= LOG_LEVEL.error then
        log(LOG_LEVEL.error, format, ...)
    end
end

init_log_level()

--- 只需配置 dev_common.conf `logger` 和 `logservice` 项
-- skynet.init(function ()
--     skynet.uniqueservice("loggerd")
-- end)

return logger