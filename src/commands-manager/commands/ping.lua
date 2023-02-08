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
    description = "Testing slash commands",
    type = dia.enums.appCommandType.chatInput,
    options = {
        {
            name = "message",
            description = "A custom message",
            type = dia.enums.appCommandOptionType.message,
        }
    }
}

return command