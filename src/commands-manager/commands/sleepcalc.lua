local dia = require('discordia')
local uv = require('uv')
local json = require"json"

local command = {}

function command.run(client, ia, cmd, args)
    local wake = false
    local cycleMultiply = 0
    if args.wake ~= nil then
        wake = true
        cycleMultiply = -1
        args = args.wake
    elseif args.sleep ~= nil then
        cycleMultiply = 1
        args = args.sleep
    else
        return ia:reply(
            "The average human takes around 15 minutes to fall asleep. Once you are asleep you will go through sleep cycles. One sleep cycle is about 90 minutes and a good night's sleep consists of 5-6 sleep cycles. It's best to wake up at the end of a cycle to help you feel more rested and ready to start the day."
            .."\nI will calculate the best time for you to sleep/wake up by using this information."
        )
    end

    local hour = args.hour
    local minute = args.minute
    local format = args.format

    local cycles = {
        [0] = GetTimeAsString(TimeAfterCycles(hour, minute, format, 0*cycleMultiply)),
        [1] = GetTimeAsString(TimeAfterCycles(hour, minute, format, 1*cycleMultiply)),
        [2] = GetTimeAsString(TimeAfterCycles(hour, minute, format, 2*cycleMultiply)),
        [3] = GetTimeAsString(TimeAfterCycles(hour, minute, format, 3*cycleMultiply)),
        [4] = GetTimeAsString(TimeAfterCycles(hour, minute, format, 4*cycleMultiply)),
        [5] = GetTimeAsString(TimeAfterCycles(hour, minute, format, 5*cycleMultiply)),
        [6] = GetTimeAsString(TimeAfterCycles(hour, minute, format, 6*cycleMultiply))
    }

    if wake then
        ia:reply(GenWakeMessage(cycles))
    else
        ia:reply(GenSleepMessage(cycles))
    end
    
end

function GenSleepMessage(cycles)
    return "If you wanna go to sleep at `"..cycles[0].."`, then I recommend you to wake up at `"..cycles[6].."` or `"..cycles[5].."`."
    .."\n\n"..
    "If you need to you can also wake up at the following times:\n"
    .."`"..cycles[4].."`\n"
    .."`"..cycles[3].."`\n"
    .."`"..cycles[2].."`\n"
    .."`"..cycles[1].."`\n"
end

function GenWakeMessage(cycles)
    return "If you wanna wake up at `"..cycles[0].."`, then I recommend you go to sleep at `"..cycles[6].."` or `"..cycles[5].."`."
    .."\n\n"..
    "If you need to you can also go to sleep at the following times:\n"
    .."`"..cycles[4].."`\n"
    .."`"..cycles[3].."`\n"
    .."`"..cycles[2].."`\n"
    .."`"..cycles[1].."`\n"
end

function GetTimeAsString(hour, minute, format)
    local formatStrings = {
        [0] = "am",
        [1] = "pm",
        [2] = ""
    }
    if minute < 10 then
        minute = "0"..minute
    end

    return hour..":"..minute..formatStrings[format]
end

function TimeAfterCycles(hour, minute, format, cycles)

    --convert it to 24h format
    if format ~= 2 then
        if hour > 12 then
            if format == 0 then
                format = 1
            else
                format = 0
            end
        end
        hour = hour%12
        if format == 1 then
            hour = hour + 12
        end
    end

    local minuteOffset = 0

    if cycles > 0 then
        minuteOffset = 15
    elseif cycles < 0 then
        minuteOffset = -15
    end

    minute = (minute + minuteOffset + 30*cycles)
    hour = (hour + cycles + math.floor(minute/60))%24
    minute = minute%60
    print(hour, minute)

    --if user isnt using 24h format, convert back
    if format ~= 2 then
        
        if hour >= 12 then
            format = 1
        else
            format = 0
        end

        if hour > 12 then
            hour = hour-12
        elseif hour == 0 then
            hour = 12
        end
    end

    return hour,minute,format
end

command.info = {
    name = "sleepcalc",
    description = "Calculates the best time to go to sleep/wake up.",
    type = dia.enums.appCommandType.chatInput,
    options = {
        {
            name = "sleep",
            description = "Calculate the best time to wake up.",
            type = dia.enums.appCommandOptionType.subCommand,
            options = {
                {
                    name = "hour",
                    description = "Hour of the time you will go to sleep.",
                    type = dia.enums.appCommandOptionType.number,
                    required = true,
                    min_value = 0,
                    max_value = 24
                },
                {
                    name = "minute",
                    description = "Minute of the time you- will go to sleep.",
                    type = dia.enums.appCommandOptionType.number,
                    required = true,
                    min_value = 0,
                    max_value = 60
                },
                {
                    name = "format",
                    description = "What format the time is in.",
                    type = dia.enums.appCommandOptionType.number,
                    choices = {
                        {
                            name = "AM",
                            value = 0
                        },
                        {
                            name = "PM",
                            value = 1
                        },
                        {
                            name = "24h clock",
                            value = 2
                        }
                    },
                    required = true
                }
            }
        },
        {
            name = "wake",
            description = "Calculate the best time to go to sleep.",
            type = dia.enums.appCommandOptionType.subCommand,
            options = {
                {
                    name = "hour",
                    description = "Hour of the time you wanna wake up.",
                    type = dia.enums.appCommandOptionType.number,
                    required = true,
                    min_value = 0,
                    max_value = 24
                },
                {
                    name = "minute",
                    description = "Minute of the time you wanna wake up.",
                    type = dia.enums.appCommandOptionType.number,
                    required = true,
                    min_value = 0,
                    max_value = 60
                },
                {
                    name = "format",
                    description = "What format the time is in.",
                    type = dia.enums.appCommandOptionType.number,
                    choices = {
                        {
                            name = "AM",
                            value = 0
                        },
                        {
                            name = "PM",
                            value = 1
                        },
                        {
                            name = "24h clock",
                            value = 2
                        }
                    },
                    required = true
                }
            }
        },
        {
            name = "info",
            description = "Info about how I calculate the times.",
            type = dia.enums.appCommandOptionType.subCommand
        },

    }
}

return command