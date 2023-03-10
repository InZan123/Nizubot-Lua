local fs = require('fs')
local json = require("json")
local timer = require('timer')
local dia = require("discordia")

local cotd = {}

local fd = fs.openSync("colors.json", "r")
local colors = json.parse(fs.readSync(fd, 524288))
fs.closeSync(fd)

function cotd.getCurrentColor()
    local data = _G.storageManager:getData("cotd", {})
    local dataRead = data:read()

    local currentDay = cotd.getCurrentDay()
    if dataRead.day ~= currentDay then
        return cotd.getDayColor(currentDay)
    end

    return dataRead.color or cotd.getDayColor(currentDay)
end

function cotd.getDayColor(day)
    if day > cotd.getCurrentDay() then
        return nil
    end
    math.randomseed(day)
    local color = math.random(1,#colors)
    math.randomseed(os.time())
    return colors[color]
end

function cotd.getCurrentDay()
    return math.floor(os.time()/86400)
end

function cotd.updateRole(role)
    local currentColor = cotd.getCurrentColor()
    local newColor = dia.Color.fromHex(currentColor.color)
    role:setColor(newColor)
    role:setName(currentColor.name)
    
end

function cotd:startLoop(client)
    coroutine.wrap(function()
        while true do
            timer.sleep(1000)
            local data = _G.storageManager:getData("cotd", {})
            local dataRead = data:read()
            local currentDay = cotd.getCurrentDay()
            if dataRead.day == currentDay then
                goto continue
            end
            local currentColor = cotd.getDayColor(currentDay)

            dataRead.day = currentDay
            dataRead.color = currentColor
            data:write(dataRead)

            local cotdRolesData = _G.storageManager:getData("cotdRoles", {})
            local cotdRolesRead = cotdRolesData:read()

            for guildId, roleId in pairs(cotdRolesRead) do
                local guild = client:getGuild(guildId)
                local role = guild:getRole(roleId)
                cotd.updateRole(role)
            end
            ::continue::
        end
    end)()
end

return cotd