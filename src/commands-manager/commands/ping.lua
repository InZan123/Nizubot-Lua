local dia = require('discordia')
local uv = require('uv')

local command = {}

function command.run(client, ia, cmd, args)
    local now = uv.now()
    
    ia:replyDeferred()
    
    now = uv.now()-now
    ia:reply("pong! `"..now.."ms`")
end

command.info = {
    name = "ping",
    description = "Pong!",
    type = dia.enums.appCommandType.chatInput
}

return command