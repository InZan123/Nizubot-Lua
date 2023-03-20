local dia = require('discordia')
local funs = require("src/functions")
local fs = require("fs")
local http = require('coro-http')
local os = require("os")
local timer = require('timer')
local spawn = require('coro-spawn')

local command = {}

function command.run(client, ia, cmd, args)
    coroutine.wrap(function ()
        ia:replyDeferred()
    
        local handle = spawn("sleep", {
            args={args.seconds}
        })

        handle.waitExit()


        ia:reply("I am done thinking.")
    end)()
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