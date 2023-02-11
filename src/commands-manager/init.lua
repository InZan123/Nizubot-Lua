local manager = {}

manager.commands = require("./commands")

function manager.setupCommands(client)
    local guilds = client.guilds
    for guildId in pairs(guilds) do
        manager.setupCommandsForGuild(client, guildId)
    end
end

function manager.setupCommandsForGuild(client, guildId)
    print("Updating commands for "..guildId)
    for _, command in pairs(manager.commands) do
        local succeeded = false
        --we will keep trying to create application command when it fails because sometimes it just errors for seemingly no reason.
        while not succeeded do
            if pcall(function()
                print(command.info.name)
                client:createGuildApplicationCommand(guildId, command.info)
            end) then
                succeeded = true
            else
                print("Retrying adding command")
            end
        end
    end
end

function manager.onSlashCommand(client, ia, cmd, args)
    local success, error = pcall(function() 
        local command = manager.commands[cmd.name]
        command.run(client, ia, cmd, args)
    end)

    if not success then
        print(error)
        ia:reply("Sorry! An error occured trying to run the command.\n\nHere's the error:\n"..error, true)
    end
end

return manager