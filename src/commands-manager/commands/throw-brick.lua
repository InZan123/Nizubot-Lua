local dia = require('discordia')
local funs = require("src/functions")
local fs = require("fs")
local http = require('coro-http')
local os = require("os")
local spawn = require('coro-spawn')

local command = {}

function command.run(client, ia, cmd, args)

    args = args or {}

    args.user = args.user or ia.user

    if not args.user.avatarURL or not args.user.name then
        local key, value = next(args.user)
        args.user = client:getUser(key)
        if not args.user then
            return ia:reply("Sorry, I couldn't find the user you were looking for.", true)
        end
    end

    ia:replyDeferred()

    local userId = args.user.id

    local lastPfpFetchData = _G.storageManager:getData(
        "users/"
        ..userId..
        "/lastPfpFetch"
        ,
        ""
    )

    local lastBrickPfpData = _G.storageManager:getData(
        "users/"
        ..userId..
        "/lastBrickGen"
        ,
        ""
    )

    local lastPfpFetch = lastPfpFetchData:read()

    local lastBrickPfp = lastBrickPfpData:read()

    local generatePfp = false
    local generateBrick = false

    if lastPfpFetch ~= args.user.avatarURL then
        generatePfp = true
    end

    if lastBrickPfp ~= args.user.avatarURL then
        generateBrick = true
    end

    local brickFolder = "data/generated/brick/"
    local userPfpsFolder = "data/downloads/pfps/"

    local brickGifFile = brickFolder..userId..".gif"
    local userPfpFile = userPfpsFolder..userId..".png"

    local brickGif = "generateMaterials/brick.gif"

    if not fs.existsSync(brickFolder) then
        funs.createDirRecursive(brickFolder)
    end

    if not fs.existsSync(userPfpsFolder) then
        funs.createDirRecursive(userPfpsFolder)
    end

    if generateBrick or not fs.existsSync(brickGifFile) then
        if generatePfp or not fs.existsSync(userPfpFile) then
            local res, body = http.request("GET", args.user.avatarURL)
            if res.code ~= 200 then
                return  ia:reply("Sorry, I was unable to get your avatar.", true)
            end
            local imagefile = fs.openSync(userPfpFile, "w")
            fs.writeSync(imagefile, 0, body)
            fs.closeSync(imagefile)
            lastPfpFetch = args.user.avatarURL
            lastPfpFetchData:write(lastPfpFetch)
        end
        local handle = spawn("ffmpeg", {
            args={
                "-i", brickGif,
                "-i", userPfpFile,
                "-ss", "00:00:00",
                "-t", "00:00:01.8",
                "-filter_complex", "[1:v]scale=48:48,pad=width=300:height=300:x=114:y=252:color=0x00000000[ico];[ico][0:v]overlay=0:0:enable='between(t,0,20)',split=2[out1][out2];[out2]palettegen=reserve_transparent=on[p];[out1][p]paletteuse",
                brickGifFile,
                "-y"
            }
        })
        lastBrickPfp = args.user.avatarURL
        lastBrickPfpData:write(lastBrickPfp)
        if handle then
            handle:waitExit()
        end
    end

    ia:reply{
        file="data/generated/brick/"..userId..".gif"
    }
end

command.info = {
    name = "brick",
    description = "Generate a gif of some user throwing a brick.",
    type = dia.enums.appCommandType.chatInput,
    options = {
        {
            type = dia.enums.appCommandOptionType.user,
            name = "user",
            description = "The user to throw the brick."
        }
    }
}

return command