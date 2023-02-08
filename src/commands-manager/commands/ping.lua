local dia = require('discordia')
local uv = require('uv')

local command = {}

function command.run(client, ia, cmd, args)
    local now = uv.now()
    local msg = ia:reply("pong!", false)
    
    now = uv.now()-now
    ia:getReply():update{content = "pong! `"..now.."ms`"}
end

command.info = {
    name = "ping",
    description = "Pong!",
    type = dia.enums.appCommandType.chatInput
}

return command