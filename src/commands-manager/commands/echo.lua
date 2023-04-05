local dia = require('discordia')
local json = require('json')

local commands = {}
local echo = {}
local adminecho = {}

function echo.run(client, ia, cmd, args)
    if args == nil then
        ia:reply("**\n**", false)
        return
    end
    if args.embeds ~= nil then
        args.embeds = json.parse(args.embeds)
        if type(args.embeds) ~= "table" then
            return ia:reply("Please send accurate JSON embed data.", true)
        end
        if not args.embeds[1] then
            args.embeds = {args.embeds}
        end
    end
    args.allowed_mentions={parse={}}
    local success, err = ia:reply(args, false)
    if not success then
        ia:reply("Failed to send message.\n\nHere's the error:\n"..err, true)
    end
end

function adminecho.run(client, ia, cmd, args)
    if args.clean then
        args = args.clean

        if next(args) == nil then
            ia.channel:send("**\n**")
            ia:reply("I've sent the empty message.", true)
            return
        end
        if args.embeds ~= nil then
            args.embeds = json.parse(args.embeds)
            if type(args.embeds) ~= "table" then
                return ia:reply("Please send accurate JSON embed data.", true)
            end
            if not args.embeds[1] then
                args.embeds = {args.embeds}
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

        args.message_id = nil

        if next(args) == nil then
            message:update{content="**\n**"}
            ia:reply("I've edited the message.", true)
            return
        end
        if args.embeds ~= nil then
            args.embeds = json.parse(args.embeds)
            if type(args.embeds) ~= "table" then
                return ia:reply("Please send accurate JSON embed data.", true)
            end
            if not args.embeds[1] then
                args.embeds = {args.embeds}
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
            name = "embeds",
            description = "Embeds of the message.",
            type = dia.enums.appCommandOptionType.string
        },
        {
            name = "content",
            description = "Contents of the message.",
            type = dia.enums.appCommandOptionType.string,
            max_length = 2000
        }
    }
}

adminecho.info = {
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
                    name = "embeds",
                    description = "Embeds of the message.",
                    type = dia.enums.appCommandOptionType.string
                },
                {
                    name = "content",
                    description = "Contents of the message.",
                    type = dia.enums.appCommandOptionType.string,
                    max_length = 2000
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
                    name = "embeds",
                    description = "Embeds of the message.",
                    type = dia.enums.appCommandOptionType.string
                },
                {
                    name = "content",
                    description = "Contents of the message.",
                    type = dia.enums.appCommandOptionType.string,
                    max_length = 2000
                }
            }
        }
    }
}
adminecho.permissions = {
    {
        permission = dia.enums.permission.sendMessages,
        failMessage = "This command requires that I have the \"Send Messages\" permission. Please make sure I have it."
    }
}


table.insert(commands, echo)
table.insert(commands, adminecho)

return commands