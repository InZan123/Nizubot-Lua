local uv = require("uv")
local json = require('json')
local fs = require('fs')
local dia = require('discordia')
local diacmd = require("discordia-slash")
local interactions = require("discordia-interactions")

CommandsManager = require("./src/commands-manager")
local client = dia.Client():useApplicationCommands()

client:on('ready', function()
    CommandsManager.setupCommands(client)
end)

client:on("slashCommand", function(ia, cmd, args)
    CommandsManager.onSlashCommand(client, ia, cmd, args)
end)


fs.open("token", "r", function (err, fd)
    if err then
        return error("Couldn't read token. Make sure you create a file named 'token' which contains the token.\nError message: "..err)
    end
    local token = fs.readSync(fd)
    client:run('Bot '..token)
end)
