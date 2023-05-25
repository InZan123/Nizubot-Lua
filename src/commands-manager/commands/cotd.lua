local dia = require('discordia')
local os = require("os")
local fs = require("coro-fs")
local spawn = require("coro-spawn")

local command = {}

function command.run(client, ia, cmd, args)

    args = args or {}

    ia:replyDeferred()

    local currentDay = _G.cotd.getCurrentDay()

    local workingDay = currentDay
    
    local title = "Color of the day"
    local dateDescription = "Next color"
    local dateOffset = 86400

    local currentColor

    if args.day then
        currentColor, err = _G.cotd.getDayColor(args.day)
        if currentColor == nil then
            return ia:reply(err, true)
        end
        workingDay = args.day
        title = "Color of day "..workingDay
        dateDescription = "COTD during"
        dateOffset = 0
    else
        currentColor = _G.cotd.getCurrentColor()
    end

    local colorsFolder = _G.dataPath.."/generated/colors/"

    local imageName = currentColor.color..".png"

    local colorImage = colorsFolder..imageName

    if not fs.stat(colorsFolder) then
        fs.mkdirp(colorsFolder)
    end

    if not fs.stat(colorImage) then
        print("Generating color "..currentColor.color)
        local handle = spawn("ffmpeg", {
            args={
                "-f", "lavfi",
                "-i", "color=size=255x255:duration=10:color="..currentColor.color,
                colorImage,
                "-y"
            }
        })
        if handle then
            handle:waitExit()
        end
    end

    local embed = {
        title = title,
        description = "**"..currentColor.name.."** (#"..currentColor.color:upper()..")",
        image = {
            url = "attachment://"..imageName
        },
        footer = {
            text = "Day "..workingDay.." | "..dateDescription
        },
        timestamp = os.date("!%Y-%m-%dT%TZ", workingDay*86400+dateOffset)
    }

    ia:reply{embed=embed, file=colorImage}

end

command.info = {
    name = "cotd",
    description = "Get the current color of the day.",
    type = dia.enums.appCommandType.chatInput,
    options = {
        {
            name = "day",
            description = "The day you wanna get the color of.",
            type = dia.enums.appCommandOptionType.integer,
            min_value = 0
        }
    }
}

return command