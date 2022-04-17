local skynet = require "skynet"
local file_logger = {}

function file_logger.log(filepath, level, str)
    skynet.send(".file_loggerd", "lua", "log", filepath, level, str)
end

skynet.init(function ()
    skynet.uniqueservice("file_loggerd")
end)

return file_logger