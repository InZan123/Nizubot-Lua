local fs = require('fs')
local json = require("json")
local timer = require('timer')
local dia = require("discordia")
local http = require('coro-http')

local cotd = {}

local apiLink = "https://api.color.pizza/v1/"

function cotd.getCurrentColor()
    local currentDay = cotd.getCurrentDay()
    return cotd.getDayColor(currentDay)
end

function cotd.getDayColor(day)
    if day > cotd.getCurrentDay() then
        return nil, "We have not reached that day yet."
    end
    
    local data = _G.storageManager:getData("cotds", {})
    local dataRead = data:read()

    local color = dataRead[tostring(day)]
    print(color)
    if color then
        return color
    end

    color = cotd.generateDayColor(day)
    if color == nil then
        return nil, "Sorry. Problems occured trying to generate the color."
    end
    dataRead[tostring(day)] = color
    data:write(dataRead)
    
    return color
end

function cotd.generateDayColor(day)
    math.randomseed(day)
    local r = string.format("%x", math.random(0,255))
    r = #r == 2 and r or "0"..r
    local g = string.format("%x", math.random(0,255))
    g = #g == 2 and g or "0"..g
    local b = string.format("%x", math.random(0,255))
    b = #b == 2 and b or "0"..b
    local hexColor = r..g..b
    math.randomseed(os.time())

    local res, body = http.request("GET", apiLink.."?values="..hexColor)

    if res.code ~= 200 then
        return nil
    end

    local parsedBody = json.parse(body)

    local color = {
        color = parsedBody.colors[1].hex:sub(2),
        name = parsedBody.colors[1].name
    }

    return color
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
            local data = _G.storageManager:getData("cotdRolesDay", {})
            local rolesDay = data:read()
            local currentDay = cotd.getCurrentDay()
            if rolesDay == currentDay then
                goto continue
            end

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

            data:write(currentDay)

            ::continue::
        end
    end)()
end

return cotd