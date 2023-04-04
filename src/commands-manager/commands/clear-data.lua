local dia = require('discordia')
local uv = require('uv')
local json = require"json"

local command = {}

function command.run(client, ia, cmd, args)

    local dms = ia.channel.type == dia.enums.channelType.private

    if dms then
        _G.storageManager:deleteData(
            "users/"..ia.user.id
        )
    else
        _G.storageManager:deleteData(
            "servers/"..ia.guild.id
        )
    end
    ia:reply("Successfully cleared all data.", true)
    
end

command.info = {
    name = "clear-data",
    description = "Clears all data I have on this guild/user. (Things such as reminders/reaction roles will be reset.)",
    type = dia.enums.appCommandType.chatInput,
    default_member_permissions = "0"
}

return command