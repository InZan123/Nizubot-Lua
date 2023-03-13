local dia = require('discordia')
local json = require('json')

local command = {}

function command.run(client, ia, cmd, args)
    if args.message then
        args = args.message

        local message = ia.channel:getMessage(args.message_id)

        local replyMessage = ""

        if message.content ~= "" then
            replyMessage=replyMessage.."content:\n```"..message.content.."```\n\n"
        end

        if message.embeds then
            replyMessage=replyMessage.."embeds:\n```"..json.stringify(message.embeds).."```\n\n"
        end

        if message.attachments then
            replyMessage=replyMessage.."attachments:\n```"..json.stringify(message.attachments).."```\n\n"
        end

        ia:reply(replyMessage,true)
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

return command