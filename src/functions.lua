local funs = {}

local durationPrefixes = {
    s = 1,
    m = 60,
    h = 3600,
    d = 86400,
    w = 604800,
    y = 31556926
}

function funs.trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function funs.round(number)
    return math.floor(number + 0.5)
end

function funs.roundToDecimal(number, decimals)
    local multiply = 10^decimals
    return funs.round(number*multiply)/multiply
end

function funs.parseDuration(durationString)
    local totalDuration = 0
    for w in durationString:gmatch("%S+") do
        local prefix = w:sub(-1)
        local amount = w:sub(1, #w-1)

        print(prefix, amount)

        local multiply = durationPrefixes[prefix]

        if multiply == nil then
            return nil
        end

        totalDuration = totalDuration + amount*multiply
    end
    return totalDuration
end

return funs