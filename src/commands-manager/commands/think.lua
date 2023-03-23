local dia = require('discordia')
local funs = require("src/functions")
local fs = require("fs")
local http = require('coro-http')
local os = require("os")
local timer = require('timer')
local spawn = require('coro-spawn')

local command = {}

function command.run(client, ia, cmd, args)
    ia:replyDeferred()

    local handle

    if _G.os_name == "Windows_NT" then
        handle = spawn("powershell", {
            args={"sleep", args.seconds}
        })
    else
        handle = spawn("sleep", {
            args={args.seconds}
        })
    end

    if handle then
        handle:waitExit()
    end

    ia:reply("I am done thinking.")
end

command.info = {
    name = "think",
    description = "I will think for a bit.",
    type = dia.enums.appCommandType.chatInput,
    options = {
        {
            type = dia.enums.appCommandOptionType.integer,
            name = "seconds",
            description = "Seconds to think.",
            required = true
        }
    }
}

return command