local dia = require('discordia')
local uv = require('uv')
local json = require"json"

local command = {}

function command.run(client, ia, cmd, args)
    if args.add ~= nil then
        
        local message = ia.channel:getMessage(args.add.messsage_id)

        if message == nil then return ia:reply("Please provide an actual message id!", true) end
        
        if args.add.role == nil then return ia:reply("Please provide an actual role!", true) end

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

            return ia:reply("Sucessfully added reaction role!\nTo remove the reaction role, simply remove my reaction or run `/reactionrole remove`.", true)
        else
            return ia:reply("Something happened while trying to react to message.", true)
        end
    elseif args.remove ~= nil then
        
        local message = ia.channel:getMessage(args.remove.messsage_id)

        if message == nil then return ia:reply("Please provide an actual message id!", true) end
        
        local emojiId = args.remove.emoji
        if emojiId == nil then
            return ia:reply("Please provide an emoji to remove!", true)
        end
        if emojiId:sub(1, 2) == "<:" and emojiId:sub(-1) == ">" then
            emojiId = emojiId:sub(3):sub(1, -2)
        end


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
        
        if dataRead[emojiId] == nil then
            return ia:reply("This message doesn't have this reaction.", true)
        end
        dataRead[emojiId] = nil;

        data:write(dataRead)

        local success = message:removeReaction(emojiId)

        return ia:reply("Sucessfully removed reaction role!", true)
    end
end

command.info = {
    name = "reactionrole",
    dm_permission = false,
    description = "Reaction role.",
    type = dia.enums.appCommandType.chatInput,
    default_member_permissions = 268435520, --manage roles and add reactions
    options = {
        {
            name = "add",
            description = "Add reaction role to message.",
            type = dia.enums.appCommandOptionType.subCommand,
            options = {
                {
                    name = "messsage_id",
                    description = "ID of the message.",
                    type = dia.enums.appCommandOptionType.string,
                    required = true
                },
                {
                    name = "emoji",
                    description = "The emoji to react to.",
                    type = dia.enums.appCommandOptionType.string,
                    required = true
                },
                {
                    name = "role",
                    description = "Role to give.",
                    type = dia.enums.appCommandOptionType.role,
                    required = true
                }
            }
        },
        {
            name = "remove",
            description = "Remove reaction role from message.",
            type = dia.enums.appCommandOptionType.subCommand,
            options = {
                {
                    name = "messsage_id",
                    description = "ID of the message.",
                    type = dia.enums.appCommandOptionType.string,
                    required = true
                },
                {
                    name = "emoji",
                    description = "The emoji to remove.",
                    type = dia.enums.appCommandOptionType.string,
                    required = true
                }
            }
        }
    }
}

return command