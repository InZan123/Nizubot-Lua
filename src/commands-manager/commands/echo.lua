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
    local success, err = ia:reply(args, false)
    if not success then
        ia:reply("Failed to send message.\n\nHere's the error:\n"..err, true)
    end
end

function cleanecho.run(client, ia, cmd, args)
    if args.clean then
        args = args.clean
        if next(args) == nil then
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
        local success, err = ia.channel:send(args)
        if success then
            ia:reply("I've sent the message.", true)
        else
            ia:reply("Failed to send message.\n\nHere's the error:\n"..err, true)
        end
    elseif args.edit then
        args = args.edit
        
        local message = ia.channel:getMessage(args.message_id)

        if message == nil then return ia:reply("Please provide an actual message id!", true) end
        if message.author.id ~= client.user.id then return ia:reply("Please provide a message sent by me!", true) end

        if next(args) == nil then
            message:update("**\n**")
            ia:reply("I've edited the message.", true)
            return
        end
        if args.embed ~= nil then
            args.embed = json.parse(args.embed)
            if type(args.embed) ~= "table" then
                return ia:reply("Please send accurate JSON embed data.", true)
            end
        end
        local success, err = message:update(args)
        if success then
            ia:reply("I've edited the message.", true)
        else
            ia:reply("Failed to edit message.\n\nHere's the error:\n"..err, true)
        end
    end
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
    name = "adminecho",
    description = "I will say what you want.",
    type = dia.enums.appCommandType.chatInput,
    default_member_permissions = 0,
    options = {
        {
            name = "clean",
            description = "I will say what you want but not show that you ran a command.",
            type = dia.enums.appCommandOptionType.subCommand,
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
        },
        {
            name = "edit",
            description = "I will edit a message sent by me.",
            type = dia.enums.appCommandOptionType.subCommand,
            options = {
                {
                    name = "message_id",
                    description = "ID of the message.",
                    type = dia.enums.appCommandOptionType.string,
                    required = true
                },
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
    }
}

table.insert(commands, echo)
table.insert(commands, cleanecho)

return commands