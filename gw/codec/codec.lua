
local protobuf = require "gw.codec.protobuf"

local codec = {}

--- 新建codec实例
-- @param[type=table] conf 配置
-- @usage
--  -- protobuf
--  local codecobj = codec.new({
--    type = "protobuf",
--    pbfile = "proto/protobuf/all.bytes",
--    idfile = "proto/protobuf/message_define.bytes",
--  })
function codec.new(conf)
    local self = {}
    if conf.type == "protobuf" then
        self.proto = protobuf.new(conf)
    else
        assert(false, conf.type)
    end
    return setmetatable(self, {__index = codec})
end

--- 重新加载协议
function codec:reload()
    self.proto:reload()
end

--- 打包消息
-- @param[type=table] msg 消息
-- @return[type=string] 打出的二进制数据
-- @usage
--  local bin = codecobj:pack_message({
--    ud = ud,     -- 自定义数据
--    cmd = cmd,   -- 协议名
--    args = args, -- 协议参数
--  })
function codec:pack_message(msg)
    return self.proto:pack_message(msg)
end

--- 解包消息
-- @param[type=string] msg 消息二进制数据
-- @return[type=table] 解出的消息
function codec:unpack_message(msg)
    return self.proto:unpack_message(msg)
end

return codec
