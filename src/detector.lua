local dia = require("discordia")

local detector = {}

function detector:addMessageDetect(type, key, response, caseSensitive, guildId, dms)
    local messageDetectors

    if dms then
        messageDetectors = _G.storageManager:getData(
            "users/"
            ..guildId..
            "/messageDetectors"
            ,
            {}
        )
    else
        messageDetectors = _G.storageManager:getData(
            "servers/"
            ..guildId..
            "/messageDetectors"
            ,
            {}
        )
    end

    local messageDetectorsRead = messageDetectors:read()

    if #messageDetectorsRead >= 25 then
        return false, "You can only have a max amount of 25 message detectors."
    end
    

    local detectorElement = {
        detectionType = type,
        key = key,
        response = response,
        caseSensitive = caseSensitive
    }
    
    table.insert(messageDetectorsRead, detectorElement)

    messageDetectors:write(messageDetectorsRead)

    return true
end

function detector:removeMessageDetect(index, guildId, dms)

    local messageDetectors

    if dms then
        messageDetectors = _G.storageManager:getData(
            "users/"
            ..guildId..
            "/messageDetectors"
            ,
            {}
        )
    else
        messageDetectors = _G.storageManager:getData(
            "servers/"
            ..guildId..
            "/messageDetectors"
            ,
            {}
        )
    end

    local messageDetectorsRead = messageDetectors:read()

    print(index)
    print(messageDetectorsRead[index])

    if messageDetectorsRead[index] ~= nil then
        table.remove(messageDetectorsRead, index)
        messageDetectors:write(messageDetectorsRead)
        return true
    end
    return false, "Index isn't valid."
end

function detector:getMessageDetects(guildId, dms)
    local messageDetectors

    if dms then
        messageDetectors = _G.storageManager:getData(
            "users/"
            ..guildId..
            "/messageDetectors"
            ,
            {}
        )
    else
        messageDetectors = _G.storageManager:getData(
            "servers/"
            ..guildId..
            "/messageDetectors"
            ,
            {}
        )
    end

    local messageDetectorsRead = messageDetectors:read()

    return messageDetectorsRead
end

function detector:start(client)

    if self.hasStarted then
        return
    end

    self.hasStarted = true

    client:on("messageCreate", function(message)

        if message.author.bot then return end

        local content = message.content
        local channel = message.channel

        local dms
        if message.channel.type == dia.enums.channelType.private then
            dms = true
        else
            dms = false
        end

        local messageDetectors

        if dms then
            messageDetectors = _G.storageManager:getData(
                "users/"
                ..message.author.id..
                "/messageDetectors"
                ,
                {}
            )
        else
            messageDetectors = _G.storageManager:getData(
                "servers/"
                ..message.guild.id..
                "/messageDetectors"
                ,
                {}
            )
        end

        local messageDetectorsRead = messageDetectors:read()

        for i, v in pairs(messageDetectorsRead) do

            local key = (not v.caseSensitive and v.key:lower()) or v.key
            local content = (not v.caseSensitive and content:lower()) or content

            if v.detectionType == 1 then --Starts with
                if content:sub(1,#key)==key then
                    channel:send(v.response)
                    break
                end
            elseif v.detectionType == 2 then --Contains
                if content:find(key) then
                    channel:send(v.response)
                    break
                end
            elseif v.detectionType == 3 then --Ends with
                if content:sub(-#key) == key then
                    channel:send(v.response)
                    break
                end
            elseif v.detectionType == 4 then --Equals
                if content == key then
                    channel:send(v.response)
                    break
                end
            end
        end
    end)
end

return detector