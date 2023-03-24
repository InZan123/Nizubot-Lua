local dia = require("discordia")

local subCommandNames = require('fs').scandirSync("./src/commands-manager/commands/genmeme")

local subCommandsFunctions = {}
local subCommandsInfo = {}

function HandleCommandBundle(subCommandsBundle)
    for _, subCommand in pairs(subCommandsBundle) do
        if subCommand[1] ~= nil then
            HandleCommandBundle(subCommand)
        end
        subCommandsFunctions[subCommand.info.name] = subCommand.run
        table.insert(subCommandsInfo, subCommand.info)
    end
end

for name, _ in subCommandNames do
    if name == "init.lua" then goto continue end
    local subCommand = require("./"..name)
    if next(subCommand) == nil then
        goto continue
    end
    if subCommand[1] ~= nil then
        HandleCommandBundle(subCommand)
        goto continue
    end
    subCommandsFunctions[subCommand.info.name] = subCommand.run
    table.insert(subCommandsInfo, subCommand.info)
    ::continue::
end

local command = {}

function command.run(client, ia, cmd, args)
    for i, v in pairs(subCommandsInfo) do
        local args = args[v.name]
        local commandFunc = subCommandsFunctions[v.name]
        if args and commandFunc then
            return commandFunc(client, ia, cmd, args)
        end
    end
end

command.info = {
    name = "genmeme",
    description = "I will generate a meme.",
    type = dia.enums.appCommandType.chatInput,
    options = subCommandsInfo
}

return command