local dia = require('discordia')
local uv = require('uv')
local json = require"json"

local command = {}

function command.run(client, ia, cmd, args)

    local data = _G.storageManager:getData("storing")

    data:write(args.data)

    ia:reply("Data stored!", false)
    
end

command.info = {
    name = "store",
    dm_permission = false,
    description = "Stores data.",
    type = dia.enums.appCommandType.chatInput,
    options = {
        {
            name = "data",
            description = "Data to store.",
            type = dia.enums.appCommandOptionType.string,
            required = true,
            max_length = 1000
        }
    }
}

return command