local dia = require('discordia')
local uv = require('uv')
local json = require"json"

local command = {}

function command.run(client, ia, cmd, args)
    if args.create then
        local name = args.create.name or "<cotd>"
        local cotdRolesData = _G.storageManager:getData("cotdRoles", {})
        local cotdRolesRead = cotdRolesData:read()


        

        if cotdRolesRead[ia.guild.id] then
            return ia:reply("You already have a COTD role! <@&"..cotdRolesRead[ia.guild.id].id..">", true)
        end

        if not ia.guild.me:hasPermission(268435456) then
            return ia:reply("I am unable to update this role because I don't have the \"Manage Roles\" permission.", true)
        end

        local role, err = ia.guild:createRole(name)

        if not role then
            return ia:reply("Sorry, it seems like I wasn't able to create the role. \n\nHere's the error:\n"..err, true)
        end

        local success, updateErr = _G.cotd.updateRole(role, name)

        if not success then
            return ia:reply("Sorry, it seems like I wasn't able to create the role properly. \n\nHere's the error:\n"..updateErr, true)
        end

        cotdRolesRead[ia.guild.id] = {
            id = role.id,
            name = name
        }
        cotdRolesData:write(cotdRolesRead)

        ia:reply("Successfully made <@&"..role.id.."> a COTD role.\nPlease remember to not put this role above my highest role or else I wont be able to edit it.", true)
    elseif args.remove then
        local cotdRolesData = _G.storageManager:getData("cotdRoles", {})
        local cotdRolesRead = cotdRolesData:read()
        local roleInfo = cotdRolesRead[ia.guild.id]
        if roleInfo == nil then
            return ia:reply("This guild does not have a COTD role.", true)
        end
        cotdRolesRead[ia.guild.id] = nil
        cotdRolesData:write(cotdRolesRead)
        if args.remove.delete then
            local role = ia.guild:getRole(roleInfo.id)
            if role then
                if not role:delete() then
                    ia:reply("<@&"..roleInfo.id.."> is no longer a COTD role but I was unable to delete it.", true)
                end
            end
            ia:reply("<@&"..roleInfo.id.."> has been successfully deleted.", true)
        else
            ia:reply("<@&"..roleInfo.id.."> is no longer a COTD role.", true)
        end
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
            name = "create",
            description = "Create a role which will change color based on the COTD.",
            type = dia.enums.appCommandOptionType.subCommand,
            options = {
                {
                    name = "name",
                    description = "The name of the role. <cotd> is replaced by the name of the color. (Default: <cotd>)",
                    type = dia.enums.appCommandOptionType.string
                }
            }
        },
        {
            name = "remove",
            description = "Stop changing the color of your COTD role.",
            type = dia.enums.appCommandOptionType.subCommand,
            options = {
                {
                    name = "delete",
                    description = "If you wanna delete the role from the guild or not. (Default: False)",
                    type = dia.enums.appCommandOptionType.boolean
                }
            }
        }
    }
}

return command