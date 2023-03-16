local dia = require('discordia')

local command = {}

function command.run(client, ia, cmd, args)
    if args.user then
        
        args = args.user

        if not args.user.avatarURL or not args.user.name then
            local key, value = next(args.user)
            args.user = client:getUser(key)
            if not args.user then
                return ia:reply("Sorry, I couldn't find the user you were looking for.", true)
            end
        end

        if not args.user then
            args.user = ia.user
        end
        local embed = {
            title = args.user.name.."'s avatar",
            image = {
                url = args.user.avatarURL.."?size=4096"
            }
        }
        ia:reply{embed=embed}
    elseif args.emoji then
        args = args.emoji
        print(args.emoji)
        local emojiId = args.emoji
        if emojiId:sub(1, 2) == "<:" and emojiId:sub(-1) == ">" then
            emojiId = emojiId:sub(3):sub(1, -2)
        end
        for str in string.gmatch(emojiId, "([^:]+)") do
            emojiId = str --this will get the last element which is the ID (emojiName:ID)
        end

        local emoji = client:getEmoji(emojiId)
        if not emoji then
            return ia:reply("Please provide a custom emoji.", false)
        end

        local embed = {
            title = emoji.name.."'s icon",
            image = {
                url = emoji.url.."?size=4096"
            }
        }

        ia:reply{embed=embed}
    else
        local embed
        if ia.channel.type == dia.enums.channelType.private then
            embed = {
                title = client.user.name.."'s avatar",
                image = {
                    url = client.user.avatarURL.."?size=4096"
                }
            }
        else
            embed = {
                title = ia.guild.name.."'s icon",
                image = {
                    url = ia.guild.iconURL.."?size=4096"
                }
            }
        end
        ia:reply{embed=embed}
    end
end

command.info = {
    name = "icon",
    description = "Get the icon of whatever you want.",
    type = dia.enums.appCommandType.chatInput,
    options = {
        {
            type = dia.enums.appCommandOptionType.subCommand,
            name = "user",
            description = "Get the profile picture of a certain user.",
            options = {
                {
                    type = dia.enums.appCommandOptionType.user,
                    name = "user",
                    description = "The user to get the profile picture from."
                }
            }
        },
        {
            type = dia.enums.appCommandOptionType.subCommand,
            name = "server",
            description = "Get the icon of the server.",
        },
        {
            type = dia.enums.appCommandOptionType.subCommand,
            name = "emoji",
            description = "Get the icon of a custom emoji.",
            options = {
                {
                    type = dia.enums.appCommandOptionType.string,
                    name = "emoji",
                    description = "The custom emoji to get the icon from.",
                    required = true
                }
            }
        }
    }
}

return command