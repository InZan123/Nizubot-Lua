local uv = require("uv")
local os = require("os")
local json = require('json')
local fs = require('fs')
local dia = require('discordia')
local diacmd = require("discordia-slash")
local interactions = require("discordia-interactions")
local client = dia.Client():useApplicationCommands()

client:on('ready', function()
	print('Logged in as '.. client.user.username)
    client:createGuildApplicationCommand("1011643968813006968", {
        name = "ping",
        description = "Testing slash commands",
        type = dia.enums.appCommandType.chatInput,
        options = {
            {
                name = "message",
                description = "A custom message",
                type = dia.enums.appCommandOptionType.string,
            }
        }
    })
end)

client:on("slashCommand", function(ia, cmd, args)
    local now = uv.now()
    local msg = ia:reply("pong!", false)
    
    now = (uv.now()-now)
    ia:getReply():update{content = "pong! `"..now.."ms`"}
end)


fs.open("token", "r", function (err, fd)
    if err then
        return error("Couldn't read token. Make sure you create a file named 'token' which contains the token.\nError message: "..err)
    end
    local token = fs.readSync(fd)
    client:run('Bot '..token)
end)
