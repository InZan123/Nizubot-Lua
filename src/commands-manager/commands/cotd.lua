local dia = require('discordia')
local os = require("os")
local fs = require("coro-fs")
local spawn = require("coro-spawn")

local command = {}

function command.run(client, ia, cmd, args)

    args = args or {}

    local currentDay = _G.cotd.getCurrentDay()

    local workingDay = currentDay
    
    local title = "Color of the day"

    local currentColor

    if args.day then
        currentColor = _G.cotd.getDayColor(args.day)
        if currentColor == nil then
            return ia:reply("We have not reached that day yet.", true)
        end
        workingDay = args.day
        title = "Color of day "..workingDay
    else
        currentColor = _G.cotd.getCurrentColor()
    end

    local colorsFolder = "data/generated/colors/"

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
            text = "Day "..workingDay.." | Next color"
        },
        timestamp = os.date("!%Y-%m-%dT%TZ", currentDay*86400+86400)
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
            type = dia.enums.appCommandOptionType.integer
        }
    }
}

return command