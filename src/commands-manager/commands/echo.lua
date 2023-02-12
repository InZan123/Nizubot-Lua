local dia = require('discordia')
local json = require('json')

local commands = {}
local echo = {}
local cleanecho = {}

function echo.run(client, ia, cmd, args)
    if args == nil then
        ia:reply("**\n**", false)
        return
    end
    if args.embed ~= nil then
        args.embed = json.parse(args.embed)
        if type(args.embed) ~= "table" then
            return ia:reply("Please send accurate JSON embed data.", true)
        end
    end
    ia:reply(args, false)
end

function cleanecho.run(client, ia, cmd, args)
    if args == nil then
        ia.channel:send("**\n**")
        ia:reply("I've sent the empty message.", true)
        return
    end
    if args.embed ~= nil then
        args.embed = json.parse(args.embed)
        if type(args.embed) ~= "table" then
            return ia:reply("Please send accurate JSON embed data.", true)
        end
    end
    ia.channel:send(args)
    ia:reply("I've sent the message.", true)
end

echo.info = {
    name = "echo",
    description = "I will say what you want.",
    type = dia.enums.appCommandType.chatInput,
    options = {
        {
            name = "embed",
            description = "Embed of the message.",
            type = dia.enums.appCommandOptionType.string
        },
        {
            name = "content",
            description = "Contents of the message.",
            type = dia.enums.appCommandOptionType.string
        }
    }
}

cleanecho.info = {
    name = "cleanecho",
    description = "I will say what you say but not show that you used a slash command.",
    type = dia.enums.appCommandType.chatInput,
    default_member_permissions = 0,
    options = {
        {
            name = "embed",
            description = "Embed of the message.",
            type = dia.enums.appCommandOptionType.string
        },
        {
            name = "content",
            description = "Contents of the message.",
            type = dia.enums.appCommandOptionType.string
        }
    }
}

table.insert(commands, echo)
table.insert(commands, cleanecho)

return commands