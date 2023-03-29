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

function cotd.updateRole(role, name)
    local currentColor = cotd.getCurrentColor()
    if currentColor == nil then
        return false, "currentColor is nil idk why"
    end
    local newColor = dia.Color.fromHex(currentColor.color)
    local colorSuccess, colorErr = role:setColor(newColor)
    local renameSuccess, renameErr = role:setName(name:gsub("<cotd>", currentColor.name))
    local err = (colorErr and (colorErr.."\n") or "")..(renameErr or "")
    return (colorSuccess and renameSuccess) and true or false, err
end

function cotd:startLoop(client)
    client:on("roleDelete", function (role)
        local cotdRolesData = _G.storageManager:getData("cotdRoles", {})
        local cotdRolesRead = cotdRolesData:read()
        local guildCotdRole = cotdRolesRead[role.guild.id]
        if guildCotdRole then
            if guildCotdRole.id == role.id then
                cotdRolesRead[role.guild.id] = nil
                cotdRolesData:write(cotdRolesRead)
            end
        end
    end)
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

            local update = false
            local removeGuilds = {}

            for guildId, roleInfo in pairs(cotdRolesRead) do
                if type(roleInfo) ~= "table" then
                    roleInfo = {
                        id = roleInfo,
                        name = "<cotd>"
                    }
                    cotdRolesRead[guildId] = roleInfo
                    update = true
                end
                local guild = client:getGuild(guildId)
                local role = guild:getRole(roleInfo.id)
                if not role then
                    table.insert(removeGuilds,guildId)
                else
                    cotd.updateRole(role, roleInfo.name)
                end
            end

            for i, v in pairs(removeGuilds) do
                cotdRolesRead[v] = nil
                update = true
            end

            if update then
                cotdRolesData:write(cotdRolesRead)
            end
            ::continue::
        end
    end)()
end

return cotd