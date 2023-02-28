local reminder = {}

local timer = require('timer')

reminder.waitTime = 0

function reminder:addReminder(guildId, channelId, userId, duration, message)

    self.waitTime = 0 --Make it 0 so it can recalculate waitTime with new reminder

    local remindersData = _G.storageManager:getData("reminders", {})
    local remindersDataRead = remindersData:read()

    if not remindersDataRead[guildId] then
        remindersDataRead[guildId] = true
        remindersData:write(remindersDataRead)
    end

    local guildReminders = _G.storageManager:getData(
        "servers/"
        ..guildId..
        "/reminders"
        ,
        {}
    )
    
    local currentTime = os.time()

    local finishedTime = currentTime + duration

    local remindElement = {
        requestTime = currentTime,
        finishedTime = finishedTime,
        channelId = channelId,
        userId = userId,
        message = message,
        tries = 0
    }

    local guildRemindersRead = guildReminders:read()
    local success = false

    for i, e in ipairs(guildRemindersRead) do --insert it in a way so that finishedTime is still sorted.
        if e.finishedTime > finishedTime then
            table.insert(guildRemindersRead, i, remindElement)
            success = true
            break
        end
    end
    if not success then
        table.insert(guildRemindersRead, remindElement)
    end

    guildReminders:write(guildRemindersRead)
end

function reminder:removeReminder(guildId, channelId, userId, index)

    local remindersData = _G.storageManager:getData("reminders", {})
    local remindersDataRead = remindersData:read()

    if not remindersDataRead[guildId] then
        return false
    end

    local guildReminders = _G.storageManager:getData(
        "servers/"
        ..guildId..
        "/reminders"
        ,
        {}
    )
    local guildRemindersRead = guildReminders:read()

    local userMatches = 0

    for i, v in ipairs(guildRemindersRead) do
        if v.channelId == channelId then
            if v.userId == userId then
                userMatches = userMatches + 1
                if userMatches == index then
                    table.remove(guildRemindersRead, i)
                    guildReminders:write(guildRemindersRead)
                    return true, v
                end
            end
        end
    end
    return false
end

function reminder:listReminders(guildId, channelId, userId)

    local remindersData = _G.storageManager:getData("reminders", {})
    local remindersDataRead = remindersData:read()

    if not remindersDataRead[guildId] then
        return {}
    end

    local guildReminders = _G.storageManager:getData(
        "servers/"
        ..guildId..
        "/reminders"
        ,
        {}
    )
    local guildRemindersRead = guildReminders:read()

    local reminders = {}

    for i, v in ipairs(guildRemindersRead) do
        if v.channelId == channelId then
            if v.userId == userId then
                table.insert(reminders, v)
                guildReminders:write(guildRemindersRead)
            end
        end
    end
    return reminders
end

function reminder:startLoop(client)

    self.waitTime = 0

    coroutine.wrap(function()
        while true do
            timer.sleep(1000)

            self.waitTime = self.waitTime - 1

            if self.waitTime > 0 then
                goto continue
            end

            local currentTime = os.time()
            local nextReminderDuration = math.huge
    
            local remindersData = _G.storageManager:getData("reminders", {})
            local remindersDataRead = remindersData:read()
    
            local removeGuilds = {}
    
            for guildId, _ in pairs(remindersDataRead) do
                local guildReminders = _G.storageManager:getData(
                    "servers/"
                    ..guildId..
                    "/reminders"
                )
    
                local guildRemindersRead = guildReminders:read()
                
                if guildRemindersRead == nil or not next(guildRemindersRead) then
                    table.insert(removeGuilds, guildId)
                    goto continue
                end
    
                local guild = client:getGuild(guildId)
    
                local removeIndexes = {}
                
                for i, e in ipairs(guildRemindersRead) do

                    if e.tries > 10 then
                        print("Removing reminder. Too many attempts.")
                        table.insert(removeIndexes, 1, i)
                        goto continue
                    end

                    if e.finishedTime > currentTime then
                        nextReminderDuration = math.min(e.finishedTime, nextReminderDuration)
                        break --the other elements will have higher finishedTime.
                    end

    
                    if guild == nil then
                        e.tries = e.tries + 1
                        print("Cannot access guild. Attempt "..e.tries)
                        nextReminderDuration = 0
                        goto continue
                    end
    
                    local channel = guild:getChannel(e.channelId)
    
                    if channel == nil then
                        e.tries = e.tries + 1
                        print("Cannot access channel. Attempt "..e.tries)
                        nextReminderDuration = 0
                        goto continue
                    end

                    local messageEnding

                    if e.message ~= "" then
                        messageEnding = " with: "..e.message
                    else
                        messageEnding = "."
                    end
    
                    local timeDifference = currentTime - e.finishedTime

                    if timeDifference < 60 then
                        channel:send("<@!"..e.userId..">! <t:"..e.requestTime..":R> you told me to remind you"..messageEnding)
                    else
                        channel:send("Sorry <@!"..e.userId..">, I was supposed to remind you <t:"..e.finishedTime..":R>! <t:"..e.requestTime..":R> you told me to remind you"..messageEnding)
                    end

                    
                    table.insert(removeIndexes, 1, i)
    
                    ::continue::
                end
    
                for i, v in ipairs(removeIndexes) do
                    table.remove(guildRemindersRead, v)
                end
                if next(removeIndexes) then
                    guildReminders:write(guildRemindersRead)
                end
    
                ::continue::
            end
    
            for i, v in pairs(removeGuilds) do
                remindersDataRead[v] = nil
            end
            if next(removeGuilds) then
                remindersData:write(remindersDataRead)
            end

            self.waitTime = nextReminderDuration - currentTime

            print("Waiting until "..self.waitTime.." seconds")

            ::continue::
        end
    end)()
end

return reminder