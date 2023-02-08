local commandNames = require('fs').scandirSync("./src/commands-manager/commands")

local commands = {}

for name, _ in commandNames do
    if name == "init.lua" then goto continue end
    print(name)
    local command = require("./"..name)
    print(command.info.name)
    commands[command.info.name] = command
    ::continue::
end

return commands