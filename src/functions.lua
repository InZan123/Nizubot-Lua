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

function funs.split(inputstr, sep)
    if inputstr == nil then
        return {}
    end
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end

function funs.roundToDecimal(number, decimals)
    local multiply = 10^decimals
    return funs.round(number*multiply)/multiply
end

function funs.fancyRound(number, visibleDecimals)
    local numberStr = tostring(number)
    local splitNumber = funs.split(numberStr, ".")
    local decimal = splitNumber[2]
    if not decimal then
        decimal = ""
    end
    for i=1, #decimal do
        local char = decimal:sub(i,i)
        if char ~= "0" then
            visibleDecimals = visibleDecimals + i - 1
            break
        end
    end
    return funs.roundToDecimal(number, visibleDecimals)
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

function funs.createDirRecursive(dir)
    local success = os.execute("mkdir -p "..dir)
    if not success then
        --if it didnt work its prob on windows and we will run a command that should work
        os.execute("powershell mkdir "..dir)
    end
end

function funs.get_os_name()
    local os_type = os.getenv("OS")

    if os_type ~= nil then
        return os_type
    end

    local uname = io.popen("uname -s"):read("*l")

    if uname ~= nil then
        return uname
    end

    return "Unknown"
end

function funs.solveStringMath(str)
    if str:match("[^%d%.%+%-%*/%(%)]") then
        return nil
    end
    local fn, err = load("return "..str)
    if err then
        return nil
    end
    local success, res = pcall(fn)
    if success then
        return res
    else
        return nil
    end
end

return funs