local skynet = require "skynet"
local logger = {}

local LOG_LEVEL = {
    debug = 1,
    info = 2,
    warn = 3,
    error = 4,
}

local function init_log_level()
    if not logger.level then
        local level = skynet.getenv("log_level")
        if not level or not LOG_LEVEL[level] then
            level = LOG_LEVEL.debug
        end

        logger.level = level
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
    skynet.send(".loggerd", "lua", "log", level, str)
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

skynet.init(function ()
    skynet.uniqueservice("loggerd")
end)

return logger