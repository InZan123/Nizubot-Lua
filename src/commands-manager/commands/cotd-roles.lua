local dia = require('discordia')
local uv = require('uv')
local json = require"json"

local command = {}

function command.run(client, ia, cmd, args)
    if args.make then
        local role = args.make.role
        local cotdRolesData = _G.storageManager:getData("cotdRoles", {})
        local cotdRolesRead = cotdRolesData:read()

        if ia.guild.id == role.id then
            return ia:reply("Please provide an actual role.", true)
        end

        local reminder = ""
        if cotdRolesRead[ia.guild.id] then
            reminder = " *(Remember, you can only have one COTD role per guild)*"
        end

        cotdRolesRead[ia.guild.id] = role.id
        cotdRolesData:write(cotdRolesRead)

        _G.cotd.updateRole(role)

        ia:reply("Successfully made <@&"..role.id.."> a COTD role."..reminder, true)
    else
        local cotdRolesData = _G.storageManager:getData("cotdRoles", {})
        local cotdRolesRead = cotdRolesData:read()
        local roleId = cotdRolesRead[ia.guild.id]
        if roleId == nil then
            return ia:reply("This guild does not have a COTD role.", true)
        end
        cotdRolesRead[ia.guild.id] = nil
        cotdRolesData:write(cotdRolesRead)
        ia:reply("Successfully removed <@&"..roleId.."> as a COTD role.", true)
    end
end

command.info = {
    name = "cotdrole",
    dm_permission = false,
    description = "COTD role.",
    type = dia.enums.appCommandType.chatInput,
    default_member_permissions = "0",
    options = {
        {
            name = "make",
            description = "Make a certain role change color based on the COTD. (The name will be overwritten)",
            type = dia.enums.appCommandOptionType.subCommand,
            options = {
                {
                    name = "role",
                    description = "Role to change color.",
                    type = dia.enums.appCommandOptionType.role,
                    required = true
                }
            }
        },
        {
            name = "remove",
            description = "Stop changing the color of your COTD role.",
            type = dia.enums.appCommandOptionType.subCommand
        }
    }
}

return command