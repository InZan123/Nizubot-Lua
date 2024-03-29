local dia = require('discordia')
local json = require('json')

local command = {}

function command.run(client, ia, cmd, args)
    if args.message then
        args = args.message

        local message = ia.channel:getMessage(args.message_id)
        
        if message == nil then return ia:reply("Please provide an actual message id!", true) end

        local information = ""

        if message.content ~= "" then
            information = information.."Message Content:\n\n"..message.content.."\n\n"
        end

        if message.embeds then
            information = information.."Message Embeds:\n\n"..json.stringify(message.embeds).."\n\n"
        end

        if message.attachments then
            information = information.."Message Attachments:\n\n"..json.stringify(message.attachments).."\n\n"
        end

        ia:reply(
            {
                file={
                    "info.txt",
                    information
                }
            },
            true
        )
    end
end

command.info = {
    name = "analyze",
    description = "Gives data about things.",
    type = dia.enums.appCommandType.chatInput,
    default_member_permissions = "0",
    options = {
        {
            name = "message",
            description = "Get information about a message.",
            type = dia.enums.appCommandOptionType.subCommand,
            options = {
                {
                    name = "message_id",
                    description = "ID of message you wanna get info from.",
                    type = dia.enums.appCommandOptionType.string,
                    required = true
                }
            }
        }
    }
}

command.permissions = {
    {
        permission = dia.enums.permission.readMessages,
        failMessage = "This command requires that I have the \"Read Messages\" permission. Please make sure I have it by enabling the \"View Channels\" permissions."
    }
}

return command