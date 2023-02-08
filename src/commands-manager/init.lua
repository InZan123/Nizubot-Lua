local manager = {}

manager.commands = require("./commands")

function manager.setupCommands(client, guilds)
    guilds = guilds or client.guilds
    for guildId in pairs(guilds) do
        for key, command in pairs(manager.commands) do
            client:createGuildApplicationCommand(guildId, command.info)
        end
    end
end

function manager.onSlashCommand(client, ia, cmd, args)
    local command = manager.commands[cmd.name]
    if command == nil then return end

    command.run(client, ia, cmd, args)
end

return manager