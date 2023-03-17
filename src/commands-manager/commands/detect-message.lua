local dia = require('discordia')
local uv = require('uv')

local command = {}

local detectTypes = {
    "starts with",
    "contains",
    "ends with",
    "equals"
}

function command.run(client, ia, cmd, args)
    local dms = ia.channel.type == dia.enums.channelType.private
    if args.add then
        args = args.add
        local success, err = _G.detector:addMessageDetect(args.type, args.key, args.response, args.caseSensitive, (dms and ia.user.id) or ia.guild.id, dms)
        if success then
            ia:reply("Sure! I will now detect messages that "..detectTypes[args.type]..' "'..args.key..'".', true)
        else
            ia:reply("Sorry, I wasn't able to add that detection. "..err, true)
        end
    elseif args.remove then
        args = args.remove
        local success, err = _G.detector:removeMessageDetect(args.index, (dms and ia.user.id) or ia.guild.id, dms)
        if success then
            ia:reply("Sure! I have now removed that detection.", true)
        else
            ia:reply("Sorry, I wasn't able to delete that detection. "..err, true)
        end
    else
        local detectors = _G.detector:getMessageDetects((dms and ia.user.id) or ia.guild.id, dms)
        local embed = {
            title = "Message Detectors",
            description = "All of the message detectors in this guild.",
            fields = {},
            footer = {
                text = "Total detectors: "..#detectors
            }
        }

        for i, v in ipairs(detectors) do
            local ending = ""
            if v.caseSensitive then
                ending = " (caseSensitive)"
            end
            table.insert(embed.fields, {
                name = i..": "..v.key..ending,
                value = "type: "..detectTypes[v.detectionType]
                .."\nresponse: "..v.response
            })
        end
        ia:reply{embed=embed}
    end
end

print(dia.enums.appCommandOptionType.subCommand)

command.info = {
    name = "detectmessage",
    description = "Events for when bot detects a message.",
    type = dia.enums.appCommandType.chatInput,
    options = {
        {
            name = "add",
            description = "Add event for when detecting a message.",
            type = dia.enums.appCommandOptionType.subCommand,
            options = {
                {
                    name = "type",
                    description = "How the detection will work.",
                    type = dia.enums.appCommandOptionType.integer,
                    choices = {
                        {
                            name = "Starts with",
                            value = 1
                        },
                        {
                            name = "Contains",
                            value = 2
                        },
                        {
                            name = "Ends with",
                            value = 3
                        },
                        {
                            name = "Equals",
                            value = 4
                        }
                    },
                    required = true
                },
                {
                    name = "key",
                    description = "What it will detect.",
                    type = dia.enums.appCommandOptionType.string,
                    required = true
                },
                {
                    name = "response",
                    description = "What I will respond with after detecting it.",
                    type = dia.enums.appCommandOptionType.string,
                    required = true
                },
                {
                    name = "case-sensitive",
                    description = "If my detection should be case-sensitive. (default: False)",
                    type = dia.enums.appCommandOptionType.boolean,
                    required = false
                }
            }
        },
        {
            name = "remove",
            description = "Remove event for when detecting a message.",
            type = dia.enums.appCommandOptionType.subCommand,
            options = {
                {
                    name = "index",
                    description = "Which event you wanna remove.",
                    type = dia.enums.appCommandOptionType.integer,
                    required = true
                }
            }
        },
        {
            name = "list",
            description = "List all message events in this guild.",
            type = dia.enums.appCommandOptionType.subCommand
        }
    }
}

return command