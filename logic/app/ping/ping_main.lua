local skynet = require "skynet"
local logger = require "logger"

skynet.start(function ()
    skynet.error("pingpong_main start")
    logger.debug("hello")
    logger.info("hello")
    logger.warn("hello")
    logger.error("hello")

    local ping1 = skynet.newservice("app/ping/ping")
    local ping2 = skynet.newservice("app/ping/ping")

    skynet.send(ping1, "lua", "start", ping2)
    skynet.exit()
end)