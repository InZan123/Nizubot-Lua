local uv = require("uv")
local json = require('json')
local fs = require('fs')
local dia = require('discordia')
local diacmd = require("discordia-slash")
local interactions = require("discordia-interactions")
local funs = require("src/functions")

_G.storageManager = require('./src/storage-manager')
_G.reminder = require('./src/reminder')
_G.cotd = require("./src/cotd")

CommandsManager = require("./src/commands-manager")
local client = dia.Client{
    gatewayIntents = 3243775
}:useApplicationCommands()

client:on('ready', function()
    _G.reminder:startLoop(client)
    _G.cotd:startLoop(client)
    CommandsManager:setupCommands(client)
end)

client:on('guildCreate', function(guild)
    --CommandsManager:setupCommandsForGuild(client, guild.id)
end)

client:on("slashCommand", function(ia, cmd, args)
    CommandsManager:onSlashCommand(client, ia, cmd, args)
end)

client:on("reactionAdd", function(reaction, userId)
    ReactionAdd(reaction.message.channel, reaction.message.id, reaction.emojiHash, userId, nil)
end)

client:on("reactionAddUncached", function(channel, messageId, reactionHash, userId)
    ReactionAdd(channel, messageId, reactionHash, userId, nil)
end)

client:on("reactionRemove", function(reaction, userId)
    ReactionRemove(reaction.message.channel, reaction.message.id, reaction.emojiHash, userId, nil)
end)

client:on("reactionRemoveUncached", function(channel, messageId, reactionHash, userId)
    ReactionRemove(channel, messageId, reactionHash, userId, nil)
end)

function ReactionAdd(channel, messageId, reactionHash, userId, reaction)
    local guild = channel.parent
    local data = _G.storageManager:getData(
        "servers/"
        ..guild.id..
        "/messages/"
        ..messageId..
        "/reaction_roles"
        ,
        {}
    )
    local dataRead = data:read()
    local roleId = dataRead[reactionHash]
    if roleId == nil then return end

    local member = guild:getMember(userId)
    if member == nil then return end

    member:addRole(roleId)
end

function ReactionRemove(channel, messageId, reactionHash, userId, reaction)

    local guild = channel.parent
    local data = _G.storageManager:getData(
        "servers/"
        ..guild.id..
        "/messages/"
        ..messageId..
        "/reaction_roles"
        ,
        {}
    )
    local dataRead = data:read()

    if userId == client.user.id then
        dataRead[reactionHash] = nil
        data:write(dataRead)
        return
    end
    local roleId = dataRead[reactionHash]
    if roleId == nil then return end

    local member = guild:getMember(userId)
    if member == nil then return end

    member:removeRole(roleId)
end

fs.open("token", "r", function (err, fd)
    if err then
        return error("Couldn't read token. Make sure you create a file named 'token' which contains the token.\nError message: "..err)
    end
    local token = funs.trim(fs.readSync(fd))
    fs.closeSync(fd)
    client:run('Bot '..token)
end)