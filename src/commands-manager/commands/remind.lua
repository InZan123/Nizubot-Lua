local dia = require('discordia')
local uv = require('uv')
local json = require("json")
local funs = require("src/functions")

local command = {}

function command.run(client, ia, cmd, args)
    if args.add then
        args = args.add
        args.message = args.message or ""

        local messageEnding

        if args.message ~= "" then
            messageEnding = " with: "..args.message
        else
            messageEnding = "."
        end

        local parsedDuration = funs.parseDuration(args.duration)

        if parsedDuration == nil then
            return ia:reply("Please give me a valid duration.", true)
        end

        _G.reminder:addReminder(ia.guildId, ia.channelId, ia.user.id, parsedDuration, args.message)

        ia:reply("Sure! I will now remind you <t:"..os.time() + parsedDuration..":R>"..messageEnding)
    elseif args.remove then
        args = args.remove

        local success, removed = _G.reminder:removeReminder(ia.guildId, ia.channelId, ia.user.id, args.index)

        if success then

            local messageEnding
            if removed == nil then
                messageEnding = "."
            else
                messageEnding = " <t:"..removed.finishedTime..":R>"
                if removed.message == "" then
                    messageEnding = messageEnding.."."
                else
                    messageEnding = messageEnding..": "..removed.message
                end
            end

            ia:reply("Successfully removed reminder"..messageEnding)
        else
            ia:reply("Failed to remove reminder. Are you using a valid index?")
        end
    else
        local reminders = _G.reminder:listReminders(ia.guildId, ia.channelId, ia.user.id)
        local embed = {
            title = "Reminders",
            description = "All of your reminders on this channel.",
            fields = {},
            footer = {
                text = "Total reminders: "..#reminders
            }
        }

        for i, v in ipairs(reminders) do
            table.insert(embed.fields, {
                name = i..": <t:"..v.finishedTime..":R>",
                value = v.message
            })
        end
        ia:reply{embed=embed}
    end
end

command.info = {
    name = "remind",
    description = "Command for reminders.",
    type = dia.enums.appCommandType.chatInput,
    options = {
        {
            name = "add",
            description = "Command to make me remind you of whatever you want.",
            type = dia.enums.appCommandOptionType.subCommand,
            options = {
                {
                    name = "duration",
                    description = "When do you want me to remind you? Example: 1s 2m 3h 4d 5w 6y",
                    type = dia.enums.appCommandOptionType.string,
                    required = true
                },
                {
                    name = "message",
                    description = "Message of the reminder.",
                    type = dia.enums.appCommandOptionType.string
                }
            }
        },
        {
            name = "remove",
            description = "Command to remove a reminder.",
            type = dia.enums.appCommandOptionType.subCommand,
            options = {
                {
                    name = "index",
                    description = "Which reminder to remove. (See reminders with /remind list)",
                    type = dia.enums.appCommandOptionType.number,
                    required = true
                }
            }
        },
        {
            name = "list",
            description = "Command to list reminders.",
            type = dia.enums.appCommandOptionType.subCommand
        }
    }
}

return command