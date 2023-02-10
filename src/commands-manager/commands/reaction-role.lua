local dia = require('discordia')
local uv = require('uv')
local json = require"json"

local command = {}

function command.run(client, ia, cmd, args)
    if args.add ~= nil then
        local message = ia.channel:getMessage(args.add.messsage_id)
        if message == nil then
            return ia:reply("Please provide an actual message id!", true)
        end
        
        if args.add.role == nil then
            return ia:reply("Please provide an actual role!", true)
        end

        local emojiId = args.add.emoji
        if emojiId == nil then
            return ia:reply("Please provide an emoji to react with!", true)
        end
        if emojiId:sub(1, 2) == "<:" and emojiId:sub(-1) == ">" then
            emojiId = emojiId:sub(3):sub(1, -2)
        end

        local success = message:addReaction(emojiId)

        if success then
            
            local data = _G.storageManager:getData(
                "servers/"
                ..ia.guild.id..
                "/messages/"
                ..message.id..
                "/reaction_roles"
                ,
                {}
            )

            local dataRead = data:read()

            dataRead[emojiId] = args.add.role.id

            data:write(dataRead)

            return ia:reply("Sucessfully added reaction role!", true)
        else
            return ia:reply("Something happened while trying to react to message.", true)
        end
    end
end

command.info = {
    name = "reactionrole",
    description = "Reaction role.",
    type = dia.enums.appCommandType.chatInput,
    options = {
        {
            name = "add",
            description = "Add reaction role to message.",
            type = dia.enums.appCommandOptionType.subCommand,
            options = {
                {
                    name = "messsage_id",
                    description = "ID of the message",
                    type = dia.enums.appCommandOptionType.string
                },
                {
                    name = "emoji",
                    description = "The emoji to react to.",
                    type = dia.enums.appCommandOptionType.string
                },
                {
                    name = "role",
                    description = "Role to grant.",
                    type = dia.enums.appCommandOptionType.role
                }
            }
        }
    }
}

return command