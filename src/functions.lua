local funs = {}

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

return funs