local dia = require('discordia')
local funs = require("src/functions")
local fs = require("fs")
local http = require('coro-http')
local os = require("os")
local spawn = require('coro-spawn')
local json = require("json")

local subCommand = {}

function SanitizeString(str)
    print(str)
    str = str:gsub("\\", "\\\\")
    str = str:gsub("%%", "%%%%")
    str = str:gsub(":", "\\:")
    str = str:gsub(";", "\\;")
    str = str:gsub("|", "\\|")
    str = str:gsub("<", "\\<")
    str = str:gsub(">", "\\>")
    str = str:gsub("{", "\\{")
    str = str:gsub("}", "\\}")
    str = str:gsub("\"", "\\\"")
    str = str:gsub("'", "\\'")
    print(str)
    return str
end

function subCommand.run(client, ia, cmd, args)

    local captionFolder = "data/generated/caption/"
    local imagesFolder = "data/downloads/images/"

    if not fs.existsSync(captionFolder) then
        funs.createDirRecursive(captionFolder)
    end

    if not fs.existsSync(imagesFolder) then
        funs.createDirRecursive(imagesFolder)
    end

    print(json.stringify(args.image))

    local six_MiB_in_bytes = 6291456

    if args.image.size > six_MiB_in_bytes then
        return ia:reply("Sorry, please make sure your image is 6 MiB or less.", true)
    end

    local imageInfo = funs.split(args.image.content_type, "/")

    print(json.stringify(imageInfo))

    if imageInfo[1] ~= "image" then
        return ia:reply("Please provide an actual image.", true)
    end

    if not args.uppertext and not args.bottomtext then
        return ia:reply("Please provide some text.", true)
    end

    print(args.uppertext)

    args.uppertext = args.uppertext or ""
    args.bottomtext = args.bottomtext or ""

    local upperTexts = funs.split(args.uppertext:gsub("\\n", "\n"), "\n")
    local bottomTexts = funs.split(args.bottomtext:gsub("\\n", "\n"), "\n")

    local extension = imageInfo[2]

    local captionFile = captionFolder..ia.id.."."..extension
    local imageFile = imagesFolder..ia.id.."."..extension

    local width = args.image.width
    local height = args.image.height

    local fontsize = (args.fontsize and funs.solveStringMath(args.fontsize:gsub("width", width):gsub("height", height)))
        or (args.type == "what" and width/7) or (args.type == "overlay" and height/10) or width/10

    local breakheight = (args.breakheight and funs.solveStringMath(args.breakheight:gsub("width", width):gsub("height", height):gsub("fontsize", fontsize)))
        or fontsize/4

    local padding = (args.padding and funs.solveStringMath(args.padding:gsub("width", width):gsub("height", height):gsub("fontsize", fontsize)))
    or (args.type == "what" and width/9) or (args.type == "overlay" and height/30) or width/20

    local ffmpegFilter = "[0]"

    local font = (args.type == "what" and "Times New Roman") or "Impact"
    local fontColor = (args.type == "what" and "white") or (args.type == "overlay" and "white:bordercolor=black:borderw="..(fontsize/20)) or "black"

    if args.type == "boxes" then

        if #bottomTexts > 0 then
            local bottomHeight = padding*2 + fontsize*#bottomTexts + breakheight*(#bottomTexts-1)
            ffmpegFilter=ffmpegFilter.."pad=width=iw:height=ih+"..bottomHeight..":x=0:y=0:color=0xFFFFFF,"
        end

        if #upperTexts > 0 then
            local upperHeight = padding*2 + fontsize*#upperTexts + breakheight*(#upperTexts-1)
            ffmpegFilter=ffmpegFilter.."pad=width=iw:height=ih+"..upperHeight..":y="..upperHeight..":color=0xFFFFFF,"
        end

    elseif args.type == "what" then

        local smallBorderSize = math.ceil(height/297)*2
        local bigBorderSize = math.ceil(height/74)*2

        local bottomHeight = padding + fontsize*#bottomTexts + breakheight*math.max(#bottomTexts-1,0)
        local upperHeight = padding + fontsize*#upperTexts + breakheight*math.max(#upperTexts-1,0)

        ffmpegFilter=ffmpegFilter.."pad=width=iw+"..smallBorderSize..":height=ih+"..smallBorderSize..":x=iw/2:y=ih/2:color=0x000000,"
        ffmpegFilter=ffmpegFilter.."pad=width=iw+"..bigBorderSize..":height=ih+"..bigBorderSize..":x=iw/2:y=ih/2:color=0xFFFFFF,"

        ffmpegFilter=ffmpegFilter.."pad=width=iw:height=ih+"..upperHeight+bottomHeight..":y="..upperHeight..":color=0x000000,"

        ffmpegFilter=ffmpegFilter.."pad=width=ih*("..width.."/"..height.."):x=(iw-out_w)/2:color=0x000000,"
    end


    local fontAscent = fontsize*(1638/2048)
    local fontDescent = fontsize-fontAscent

    for i, v in ipairs(upperTexts) do

        local alignmentOffset = "-max_glyph_a+"..fontAscent+fontDescent/2
        local lineOffset = padding + (fontsize+breakheight)*(i-1)

        ffmpegFilter=ffmpegFilter.."drawtext=text='"..SanitizeString(v).."':x=(main_w-text_w)/2:y="..alignmentOffset.."+"..lineOffset..":fontsize="..fontsize..":fontcolor="..fontColor..","
    end

    for i, v in ipairs(bottomTexts) do

        local alignmentOffset = "-max_glyph_a-"..fontsize-fontAscent-fontDescent/2
        local lineOffset = padding + (fontsize+breakheight)*(#bottomTexts-i)
        
        ffmpegFilter=ffmpegFilter.."drawtext=text='"..SanitizeString(v).."':font="..font..":x=(main_w-text_w)/2:y=main_h"..alignmentOffset.."-"..lineOffset..":fontsize="..fontsize..":fontcolor="..fontColor..","
    end

    if extension == "gif" then
        ffmpegFilter=ffmpegFilter.."split=2[s0][s1];[s0]palettegen=reserve_transparent=on[p];[s1][p]paletteuse,"
    end

    ia:replyDeferred()

    local res, body = http.request("GET", args.image.url)
    if res.code ~= 200 then
        return ia:reply("Sorry, I was unable to get your image.", true)
    end
    local imageFileW = fs.openSync(imageFile, "w")
    fs.writeSync(imageFileW, 0, body)
    fs.closeSync(imageFileW)

    ffmpegFilter = ffmpegFilter:sub(1, -2) --the last character is a , so we remove it

    print(ffmpegFilter)

    local handle, err = spawn("ffmpeg", {
        args={
            "-i", imageFile,
            "-filter_complex",ffmpegFilter,
            captionFile,
            "-y"
        }
    })

    if handle then
        local code, sig = handle:waitExit()
        print(code, sig)
    else
        print(err)
    end



    ia:reply{
        file=captionFile
    }
end

subCommand.info = {
    name = "caption",
    description = "Generate an image with captions.",
    type = dia.enums.appCommandOptionType.subCommand,
    options = {
        {
            type = dia.enums.appCommandOptionType.attachment,
            name = "image",
            description = "The image to be captioned.",
            required = true
        },
        {
            type = dia.enums.appCommandOptionType.string,
            name = "type",
            description = "Which meme type you want.",
            choices = {
                {
                    name = "White boxes",
                    value = "boxes"
                },
                {
                    name = "WHAT",
                    value = "what"
                },
                {
                    name = "Overlay text",
                    value = "overlay"
                }
            },
            required = true
        },
        {
            type = dia.enums.appCommandOptionType.string,
            name = "uppertext",
            description = "What the upper text should be. (type \"\\n\" to make a new line.)"
        },
        {
            type = dia.enums.appCommandOptionType.string,
            name = "bottomtext",
            description = "What the bottom text should be. (type \"\\n\" to make a new line.)"
        },
        {
            type = dia.enums.appCommandOptionType.string,
            name = "fontsize",
            description = "Size of the font. (WHAT: width/7, Boxes: width/10, Overlay: height/10)"
        },
        {
            type = dia.enums.appCommandOptionType.string,
            name = "breakheight",
            description = "How big the space between new lines should be. (Default: fontsize/4)"
        },
        {
            type = dia.enums.appCommandOptionType.string,
            name = "padding",
            description = "Amount of empty space around the text. (WHAT: width/9, Boxes: width/20, Overlay: height/30)"
        }
    }
}

return subCommand