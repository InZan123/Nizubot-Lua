local dia = require('discordia')
local timer = require('timer')
local funs = require("src/functions")
local json = require("json")

--I feel like this might be one of the most demanding part of this bot.

local command = {}

function command.run(client, ia, cmd, args)
    
    args = args or {}

    local guild = ia.guild

    if args.user and args.index then
        return ia:reply("Please do not use the 'user' and 'index' options at the same time.", true)
    end

    args.user = args.user or {}

    if ia.channel.type == dia.enums.channelType.private then
        return SendSortedList(client, ia, args.user.id or ia.user.id, args.index, true)
    end

    --basically what this mess is, if members arent cached, cache them. Then call SendSortedList
	if #guild.members ~= guild.totalMemberCount then
        guild:requestMembers()
    end
    local tries = 0
    while true do
        tries = tries + 1
        if tries > 20 then --if it takes too long to update we give up
            return ia:reply("Please try again.\n\nGuild has "..guild.totalMemberCount.." members but I only found "..#guild.members..".", true)
        elseif #guild.members >= guild.totalMemberCount then
            return SendSortedList(client, ia, args.user.id or ia.user.id, args.index, false)
        end
        timer.sleep(100)
    end
end


function GetJoinTime(userId, members)
    return math.floor(dia.Date.fromISO(members:get(userId).joinedAt):toSeconds())
end

function SendSortedList(client, ia, targetUserId, targetIndex, dms)
    local minIndex
    local maxIndex
    local finalSortedList

    local comparisons
    local sortingMethod

    if not dms then

        local guild = ia.guild
        local sortedList = _G.storageManager:getData("servers/"..guild.id.."/sortedUsers", {})
        finalSortedList = sortedList:read()

        --Removes users that no longer exists from the sortedUsers and add users that dont exist in the sortedUsers

        local hash = {}

        local i = 1
        while i <= #finalSortedList do
            local k = finalSortedList[i]
            if guild.members:get(k) then
                i = i + 1
                hash[k] = true
            else
                table.remove(finalSortedList, i)
            end
        end
        local sortAmount = #finalSortedList/#guild.members
        for k, v in pairs(guild.members) do
            if not hash[k] then
                table.insert(finalSortedList, k)
            end
        end

        --sorting time!
        if sortAmount > 0.9 then -- if more than 90% is probably sorted, use insertion sort
            comparisons, hash = InsertionSortMembers(finalSortedList, guild.members)
            sortingMethod = "Insertion"
        else
            comparisons, hash = QuickSortMembers(finalSortedList, guild.members)
            sortingMethod = "Quick"
        end

        sortedList:write(finalSortedList)

        targetIndex = targetIndex or hash[targetUserId] or #finalSortedList+1

        maxIndex = targetIndex+4
        minIndex = targetIndex-4
        local maxOvershoot = math.max(maxIndex-#finalSortedList,0)
        local minUndershoot = -math.min(minIndex-1,0)
        maxIndex = math.min(maxIndex+minUndershoot, #finalSortedList)
        minIndex = math.max(minIndex-maxOvershoot, 1)
    else
        comparisons = 1
        sortingMethod = "Insertion"
        minIndex = 1
        maxIndex = 2
        if ia.user.createdAt < client.user.createdAt then
            finalSortedList = {
                ia.user.id,
                client.user.id
            }
        else
            finalSortedList = {
                client.user.id,
                ia.user.id
            }
        end
        
    end

    local description = ""

    local embed = {
        title = "Join order",
        footer = {
            text = sortingMethod.." sorting took "..comparisons.." comparisons."
        }
    }

    --generate description
    for i = minIndex, maxIndex do
        local member = (not dms and ia.guild.members:get(finalSortedList[i]) or nil) or client:getUser(finalSortedList[i])
        description = description.."**"..i..".** "..(member and member.tag or finalSortedList[i])
        if finalSortedList[i] == ia.user.id then
            description = description.." ***(you)***\n"
        elseif targetIndex == i or targetUserId == finalSortedList[i] then
            description = description.." ***(target)***\n"
        else
            description = description.."\n"
        end

    end

    embed.description = description

    ia:reply{embed=embed}
end

function QuickSortMembers(array, members) --table.sort uses quicksort I think
    local comparisons = 0
    local hash = {}

    table.sort(array, function(a,b)
        comparisons = comparisons + 1
        print(a)
        print(b)
        local joinedAtA = GetJoinTime(a, members)
        local joinedAtB = GetJoinTime(b, members)
        return joinedAtA < joinedAtB
    end)
    
    for i, v in pairs(array) do
        hash[v] = i
    end
    return comparisons, hash
end

function InsertionSortMembers(array, members)
    local comparisons = 0
    local len = #array
    local hash = {
        [array[1]] = 1
    }
    for j = 2, len do
        local memberId = array[j]
        local memberJoinTime = GetJoinTime(memberId, members)
        local i = j - 1
        while i > 0 and GetJoinTime(array[i], members) > memberJoinTime do
            comparisons = comparisons + 1
            array[i + 1] = array[i]
            hash[array[i + 1]] = i + 1
            i = i - 1
        end
        comparisons = comparisons + 1
        array[i + 1] = memberId
        hash[memberId] = i + 1
    end
    return comparisons, hash
end

command.info = {
    name = "joinorder",
    description = "See what order people joined at.",
    type = dia.enums.appCommandType.chatInput,
    options = {
        {
            name = "user",
            description = "Which user you wanna check.",
            type = dia.enums.appCommandOptionType.user,
        },
        {
            name = "index",
            description = "Which index you wanna check.",
            type = dia.enums.appCommandOptionType.integer,
        }
    }
}

return command