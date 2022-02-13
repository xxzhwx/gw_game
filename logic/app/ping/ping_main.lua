local skynet = require "skynet"

skynet.start(function ()
    skynet.error("pingpong_main start")
    local ping1 = skynet.newservice("app/ping/ping")
    local ping2 = skynet.newservice("app/ping/ping")

    skynet.send(ping1, "lua", "start", ping2)
    skynet.exit()
end)