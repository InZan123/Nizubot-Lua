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
    local success, err = xpcall(function()
        local command = self.commands[cmd.name]
        if command.permissions then
            if ia.guild then
                local me = ia.guild.me or ia.guild:getMember(client.user.id)
                for i, v in ipairs(command.permissions) do
                    if not me:hasPermission(ia.channel, v.permission) then
                        return ia:reply(v.failMessage, true)
                    end
                end
            end
        end

        command.run(client, ia, cmd, args)
    end,
    debug.traceback)


    if not success then
        print(err)
        ia:reply("Sorry! An error occured trying to run the command.\n\nHere's the error:\n"..err, true)
    end

end

return manager