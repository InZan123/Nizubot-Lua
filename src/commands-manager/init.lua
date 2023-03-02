local manager = {}
local json = require"json"
manager.commands = require("./commands")

function manager:setupCommands(client)
    local commands = self.commands
    local oldCommands = client:getGlobalApplicationCommands()
    for _, command in pairs(oldCommands) do
        if commands[command.name] == nil then
            print("Deleting "..command.name)
            client:deleteGlobalApplicationCommand(command.id)
        end
    end

    for _, command in pairs(commands) do

        local succeeded = false
        --we will keep trying to create application command when it fails because sometimes it just errors for seemingly no reason.
        while not succeeded do
            if pcall(function()
                print("Adding "..command.info.name)
                local success, err = client:createGlobalApplicationCommand(command.info)
                if not success then
                    print(err)
                end
            end) then
                succeeded = true
            else
                print("Retrying adding command")
            end
        end
    end
end

function manager:onSlashCommand(client, ia, cmd, args)
    local success, error = pcall(function() 
        local command = self.commands[cmd.name]
        command.run(client, ia, cmd, args)
    end)

    if not success then
        print(error)
        ia:reply("Sorry! An error occured trying to run the command.\n\nHere's the error:\n"..error, true)
    end
end

return manager