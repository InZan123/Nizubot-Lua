local reminder = {}

local timer = require('timer')

reminder.waitTime = 0

function reminder:addReminder(guildId, channelId, userId, duration, looping, message)

    local remindersData = _G.storageManager:getData("reminders", {})
    local remindersDataRead = remindersData:read()

    local reminders

    local currentReminders = self:listReminders(guildId, nil, userId)

    if #currentReminders >= 25 then
        return false, "You can only have a max amount of 25 reminders per guild."
    end

    if guildId ~= nil then
        if not remindersDataRead[guildId] then
            remindersDataRead[guildId] = {
                dms = false
            }
            remindersData:write(remindersDataRead)
        end

        reminders = _G.storageManager:getData(
            "servers/"
            ..guildId..
            "/reminders"
            ,
            {}
        )
    else
        if not remindersDataRead[userId] then
            remindersDataRead[userId] = {
                dms = true
            }
            remindersData:write(remindersDataRead)
        end
        reminders = _G.storageManager:getData(
            "users/"
            ..userId..
            "/reminders"
            ,
            {}
        )
    end
    
    local currentTime = os.time()

    local finishedTime = currentTime + duration

    local remindElement = {
        orginTime = currentTime,
        requestTime = currentTime,
        finishedTime = finishedTime,
        channelId = channelId,
        userId = userId,
        message = message,
        tries = 0,
        looping = looping
    }

    local remindersRead = reminders:read()
    local success = false

    for i, e in ipairs(remindersRead) do --insert it in a way so that finishedTime is still sorted.
        if e.finishedTime > finishedTime then
            table.insert(remindersRead, i, remindElement)
            success = true
            break
        end
    end
    if not success then
        table.insert(remindersRead, remindElement)
    end

    reminders:write(remindersRead)

    self.waitTime = math.min(self.waitTime, finishedTime)

    return true
end

function reminder:removeReminder(guildId, channelId, userId, index)

    local remindersData = _G.storageManager:getData("reminders", {})
    local remindersDataRead = remindersData:read()

    local reminderData = remindersDataRead[guildId] or remindersDataRead[userId]

    if not reminderData then
        return false
    end

    local reminders

    if reminderData.dms then
        reminders = _G.storageManager:getData(
            "users/"
            ..userId..
            "/reminders"
            ,
            {}
        )
    else
        reminders = _G.storageManager:getData(
            "servers/"
            ..guildId..
            "/reminders"
            ,
            {}
        )
    end
    
    local remindersRead = reminders:read()

    local userMatches = 0

    for i, v in ipairs(remindersRead) do
        if v.channelId == channelId then --if in dms these will be nil anyways
            if v.userId == userId then
                userMatches = userMatches + 1
                if userMatches == index then
                    table.remove(remindersRead, i)
                    reminders:write(remindersRead)
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

    local reminderData = remindersDataRead[guildId] or remindersDataRead[userId]

    if not reminderData then
        return {}
    end

    local reminders

    if reminderData.dms then
        reminders = _G.storageManager:getData(
            "users/"
            ..userId..
            "/reminders"
            ,
            {}
        )
    else
        reminders = _G.storageManager:getData(
            "servers/"
            ..guildId..
            "/reminders"
            ,
            {}
        )
    end

    local remindersRead = reminders:read()

    local remindersTable = {}

    for i, v in ipairs(remindersRead) do
        if not channelId or (v.channelId == channelId) then
            if not userId or (v.userId == userId) then
                table.insert(remindersTable, v)
            end
        end
    end
    return remindersTable
end

function reminder:startLoop(client)

    self.waitTime = 0

    coroutine.wrap(function()
        while true do
            timer.sleep(1000)

            local currentTime = os.time()

            if self.waitTime > currentTime then
                goto continue
            end

            local nextReminderTime = math.huge
    
            local remindersData = _G.storageManager:getData("reminders", {})
            local remindersDataRead = remindersData:read()
    
            local removeGuilds = {}
    
            for id, v in pairs(remindersDataRead) do
                local reminders

                if v.dms then
                    reminders = _G.storageManager:getData(
                        "users/"
                        ..id..
                        "/reminders"
                        ,
                        {}
                    )
                else
                    reminders = _G.storageManager:getData(
                        "servers/"
                        ..id..
                        "/reminders"
                        ,
                        {}
                    )
                end
    
                local remindersRead = reminders:read()
                
                if remindersRead == nil or not next(remindersRead) then
                    table.insert(removeGuilds, id)
                    goto continue
                end
    
                local guild
                if v.dms then
                    guild = client:getUser(id)
                else
                    guild = client:getGuild(id)
                end
    
                local removeIndexes = {}
    
                local addReminders = {}
                
                for i, e in ipairs(remindersRead) do

                    if e.tries > 10 then
                        print("Removing reminder. Too many attempts.")
                        table.insert(removeIndexes, 1, i)
                        goto continue
                    end

                    if e.finishedTime > currentTime then
                        nextReminderTime = math.min(e.finishedTime, nextReminderTime)
                        break --the other elements will have higher finishedTime.
                    end

    
                    if guild == nil then
                        e.tries = e.tries + 1
                        print("Cannot access guild. Attempt "..e.tries)
                        nextReminderTime = 0
                        goto continue
                    end
                    
                    local channel
                    if v.dms then
                        channel = guild:getPrivateChannel()
                    else
                        channel = guild:getChannel(e.channelId)
                    end
    
                    if channel == nil then
                        e.tries = e.tries + 1
                        print("Cannot access channel. Attempt "..e.tries)
                        nextReminderTime = 0
                        goto continue
                    end

                    local messageEnding

                    if e.message ~= "" then
                        messageEnding = " with: "..e.message
                    else
                        messageEnding = "."
                    end

                    local timeDifference = currentTime - e.finishedTime

                    if e.looping then

                        local waitTime = e.finishedTime - e.requestTime
                        local missedReminders = math.floor((currentTime-e.requestTime) / waitTime)-1

                        if missedReminders > 0 then
                            channel:send("Sorry <@!"..e.userId..">, I forgot to remind you "..missedReminders.." times! <t:"..e.orginTime..":R> you told me to keep reminding you"..messageEnding)
                        elseif timeDifference > 60 then
                            channel:send("Sorry <@!"..e.userId..">, I was supposed to remind you <t:"..e.finishedTime..":R>! <t:"..e.orginTime..":R> you told me to keep reminding you"..messageEnding)
                        else
                            channel:send("<@!"..e.userId..">! <t:"..e.orginTime..":R> you told me to keep reminding you"..messageEnding)
                        end

                        e.requestTime = e.finishedTime + waitTime * missedReminders
                        e.finishedTime = e.requestTime + waitTime
                        nextReminderTime = math.min(e.finishedTime, nextReminderTime)
                        table.insert(addReminders, e)
                    else

                        if timeDifference > 60 then
                            channel:send("Sorry <@!"..e.userId..">, I was supposed to remind you <t:"..e.finishedTime..":R>! <t:"..e.requestTime..":R> you told me to remind you"..messageEnding)
                        else
                            channel:send("<@!"..e.userId..">! <t:"..e.requestTime..":R> you told me to remind you"..messageEnding)    
                        end
                    end
                    
                    
                    if e.looping then
                    end

                    table.insert(removeIndexes, 1, i)
    
                    ::continue::
                end
    
                for i, v in ipairs(removeIndexes) do
                    table.remove(remindersRead, v)
                end

                local success = false
                for _, remindElement in ipairs(addReminders) do
                    for i, e in ipairs(remindersRead) do --insert it in a way so that finishedTime is still sorted.
                        if e.finishedTime > remindElement.finishedTime then
                            table.insert(remindersRead, i, remindElement)
                            success = true
                            break
                        end
                    end
                    if not success then
                        table.insert(remindersRead, remindElement)
                    end
                end
                
                if next(removeIndexes) then
                    reminders:write(remindersRead)
                end
    
                ::continue::
            end
    
            for i, v in pairs(removeGuilds) do
                remindersDataRead[v] = nil
            end
            if next(removeGuilds) then
                remindersData:write(remindersDataRead)
            end

            self.waitTime = nextReminderTime

            print("Waiting until "..(self.waitTime-currentTime).." seconds")

            ::continue::
        end
    end)()
end

return reminder