local dia = require('discordia')
local uv = require('uv')
local json = require"json"

local command = {}

function command.run(client, ia, cmd, args)
    args = args or {}
    local max = args.max or 0
    local min = args.min or 0
    if max == min then
        ia:reply("Please make sure the difference between 'min' and 'max' are larger than 0.", true)
        return
    end
    if max < min then
        ia:reply("Please make sure 'min' is less than 'max'.", true)
        return
    end
    ia:reply(math.random(min, max), false)
    
end

command.info = {
    name = "rng",
    description = "I will pick a random number!",
    type = dia.enums.appCommandType.chatInput,
    options = {
        {
            name = "max",
            description = "Biggest possible number.",
            type = dia.enums.appCommandOptionType.number,
            options = {
                {
                    name = "min",
                    description = "Smallest possible number.",
                    type = dia.enums.appCommandOptionType.number,
                    
                }
            }
        },
        {
            name = "min",
            description = "Smallest possible number.",
            type = dia.enums.appCommandOptionType.string,
            options = {
                {
                    name = "max",
                    description = "Biggest possible number.",
                    type = dia.enums.appCommandOptionType.string,
                }
            }
            
        }
    }
}

return command