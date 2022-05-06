
local pb = require "protobuf"

local protobuf = setmetatable({}, {__index = pb})

function protobuf.new(conf)
    local pbfile = assert(conf.pbfile)
    local idfile = assert(conf.idfile)
    local self = {
        pbfile = pbfile,
        idfile = idfile,
        message_define = {},
    }

    self.MessageProto = conf.MessageProto or "NetMessage"
    setmetatable(self, {__index = protobuf})

    self:reload()
    return self
end

function protobuf:reload()
    pb.register_file(self.pbfile)

    self.message_define = {}
    local fd = io.open(self.idfile, "rb")
    if not fd then return end

    for line in fd:lines() do
        local id, name = string.match(line, '%[(%d+)%]%s+=%s+"([%w_.]+)"')
        if id and name then
            id = assert(tonumber(id))
            assert(self.message_define[id] == nil)
            assert(self.message_define[name] == nil)
            self.message_define[id] = name
            self.message_define[name] = id
        end
    end
    fd:close()
end

function protobuf:pack_message(msg)
    local id = assert(self.message_define[msg.cmd], "unknown message name: "..msg.cmd)

    local net_msg = {
        code = msg.ud,
        proto_id = id,
    }
    if msg.args then
        net_msg.payload = protobuf.encode(msg.cmd, msg.args)
    end
    return protobuf.encode(self.MessageProto, net_msg)
end

function protobuf:unpack_message(msg)
    local net_msg = protobuf.decode(self.MessageProto, msg)
    if not net_msg then return end

    local name = assert(self.message_define[net_msg.proto_id], "unknown message id: "..net_msg.proto_id)

    local args = protobuf.decode(name, net_msg.payload)
    return {cmd = name, args = args, ud = net_msg.code}
end

return protobuf
