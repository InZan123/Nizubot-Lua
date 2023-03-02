local dia = require('discordia')
local os = require("os")
local fs = require("fs")
local json = require("json")

local command = {}

local fd = fs.openSync("colors.json", "r")
local colors = json.parse(fs.readSync(fd, 524288))
fs.closeSync(fd)

function command.run(client, ia, cmd, args)

    args = args or {}

    local currentDay = math.floor(os.time()/86400)

    local workingDay = currentDay
    
    local title = "Color of the day"

    if args.day then
        if args.day > currentDay then
            return ia:reply("We have not reached that day yet.", true)
        end
        workingDay = args.day
        title = "Color of day "..workingDay
    end

    math.randomseed(workingDay)
    local color = math.random(1,#colors)
    math.randomseed(os.time())

    local currentColor = colors[color]

    local embed = {
        title = title,
        description = "**"..currentColor.name.."** (#"..currentColor.color:upper()..")",
        image = {
            url = "https://singlecolorimage.com/get/"..currentColor.color.."/255x255"
        },
        footer = {
            text = "Day "..workingDay.." | Next color"
        },
        timestamp = os.date("!%Y-%m-%dT%TZ", currentDay*86400+86400)
    }

    ia:reply{embed=embed}

end

command.info = {
    name = "cotd",
    description = "Get the current color of the day.",
    type = dia.enums.appCommandType.chatInput,
    options = {
        {
            name = "day",
            description = "The day you wanna get the color of.",
            type = dia.enums.appCommandOptionType.number
        }
    }
}

return command