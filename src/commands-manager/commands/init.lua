local commandNames = require('fs').scandirSync("./src/commands-manager/commands")

local commands = {}

function HandleCommandBundle(commandBundle)
    for _, command in pairs(commandBundle) do
        if command[1] ~= nil then
            HandleCommandBundle(command)
        end
        commands[command.info.name] = command
    end 
end

for name, _ in commandNames do
    if name == "init.lua" then goto continue end
    local command = require("./"..name)
    if next(command) == nil then
        goto continue
    end
    if command[1] ~= nil then
        HandleCommandBundle(command)
        goto continue
    end
    commands[command.info.name] = command
    ::continue::
end

return commands