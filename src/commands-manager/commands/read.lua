local dia = require('discordia')
local uv = require('uv')
local json = require"json"

local command = {}

function command.run(client, ia, cmd, args)

    local data = _G.storageManager:getData("storing")

    ia:reply(
        {
            content = "Stored data: "..json.stringify(data:read()),
            allowed_mentions = {parse={}}
        },
        false
    )
    
end

command.info = {
    name = "read",
    description = "Reads data.",
    type = dia.enums.appCommandType.chatInput
}

return command