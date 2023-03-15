---@diagnostic disable: undefined-field
local dia = require('discordia')
local json = require"json"
local http = require('coro-http')
local os = require('os')
local fs = require('fs')
local funs = require("src/functions")

local command = {}

local fd = fs.openSync("libreTranslateUrl", "r")

if fd == nil then
    print("\27[31mCouldn't find file 'libreTranslateUrl'. The /translate command will not work.\27[0m\n")
    return nil
end

local apiLink = funs.trim(fs.readSync(fd))
fs.closeSync(fd)

function GetLanguages()
    local url = apiLink.."languages"

    local status, connected, res = pcall(function ()
        local res, body = http.request("GET", url)
        print(type(body))
        if res.code ~= 200 then
            return false, "Failed to connect to LibreTranslate.\n\n"..body
        end
        return true, body
    end)

    if not status then
        return false, "Failed to connect to LibreTranslate.\n\nNo response."
    end

    return connected, res
end

local success, languagesTemp = GetLanguages()

if not success then
    print("\27[31mCouldn't connect to libreTranslate. The /translate command will not work.\27[0m\n")
    return nil
end

languagesTemp = json.parse(languagesTemp)

local languages = {}
local languagesListEmbed = {
    title = "Supported languages",
    description = "Here are all supported languages:\n"
}

for i,v in ipairs(languagesTemp) do
    languages[v.code] = v.name
    languagesListEmbed.description = languagesListEmbed.description.."\n**"..v.code.."**: "..v.name
end

languagesTemp = nil

function Translate(text, source, target)
    if source:lower() ~= "auto" and not languages[source:lower()] then
        return false, "Failed to get language `"..source.."`. It might not be supported."
    end
    if not languages[target:lower()] then
        return false, "Failed to get language `"..target.."`. It might not be supported."
    end
    source = source:lower()
    target = target:lower()
    local url = apiLink.."translate"
    local headers = {
        {"Content-Type", "application/x-www-form-urlencoded"},
        {"Accept", "application/json"}
    }
    
    local body = "q="..text.."&source="..source.."&target="..target

    local res, body = http.request("POST", url, headers, body)
    
    if res.code ~= 200 then
        return false, "Failed to connect to LibreTranslate.\n\n"..body
    end
    
    local result = json.parse(body)

    return true, result
end

function command.run(client, ia, cmd, args)
    local message
    if args.text then
        args = args.text
    elseif args.message then
        args = args.message
        message = ia.channel:getMessage(args.message_id)
        if not message then
            return ia:reply("Please provide an actual message ID.", true)
        end
        args.text = message.content
    else
        return ia:reply{embed=languagesListEmbed}
    end

    local from = args.from or "auto"
    local to = args.to or "en"

    local success, result = Translate(args.text, from, to)

    if not success then
        return ia:reply(result, true)
    end

    from = (from:lower() == "auto" and result.detectedLanguage.language) or from

    local embedResponse = {
        title = "Translation from `"..languages[from:lower()].."` to `"..languages[to:lower()].."`",
        description = result.translatedText
    }

    if message then
        embedResponse.author = {
            name=message.author.name.." says...",
            url=message.link,
            icon_url=message.author.avatarURL
        }
    end

    ia:reply{embed=embedResponse}
end

command.info = {
    name = "translate",
    description = "Translate messages or plain text.",
    type = dia.enums.appCommandType.chatInput,
    options = {
        {
            name = "list",
            description = "List all supported languages.",
            type = dia.enums.appCommandOptionType.subCommand
        },
        {
            name = "message",
            description = "Translate a message.",
            type = dia.enums.appCommandOptionType.subCommand,
            options = {
                {
                    name = "message_id",
                    description = "ID of the message you wanna translate.",
                    type = dia.enums.appCommandOptionType.string,
                    required = true
                },
                {
                    name = "from",
                    description = "Language text is in. (default: auto)",
                    type = dia.enums.appCommandOptionType.string
                },
                {
                    name = "to",
                    description = "Language you wanna translate to. (default: en)",
                    type = dia.enums.appCommandOptionType.string
                }
            }
        },
        {
            name = "text",
            description = "Translate text.",
            type = dia.enums.appCommandOptionType.subCommand,
            options = {
                {
                    name = "text",
                    description = "Text you wanna translate.",
                    type = dia.enums.appCommandOptionType.string,
                    required = true
                },
                {
                    name = "from",
                    description = "Language text is in. (default: auto)",
                    type = dia.enums.appCommandOptionType.string
                },
                {
                    name = "to",
                    description = "Language you wanna translate to. (default: en)",
                    type = dia.enums.appCommandOptionType.string
                }
            }
        }
    }
}

return command