local apiLink = "https://openexchangerates.org/api/"

local dia = require('discordia')
local json = require"json"
local http = require('coro-http')
local os = require('os')
local fs = require('fs')
local funs = require("src/functions")

local command = {}

local fd = fs.openSync("openExchangeRatesApiKey", "r")

if fd == nil then
    print("\27[31mCouldn't find file 'openExchangeRatesApiKey'. The /currency command will not work.\27[0m\n")
    return nil
end

local apiKey = funs.trim(fs.readSync(fd))
fs.closeSync(fd)

function RequestUrl(url)
    local status, connected, res = pcall(function ()
        local res, body = http.request("GET", url)
        if res.code ~= 200 then
            return false, "Failed to connect to `openexchangerates.org`."
        end
        return true, body
    end)
    if not status then
        return false, "Failed to connect to `openexchangerates.org`."
    end
    return connected, res
end

function GetCurrencyRates()
    local connected, res = RequestUrl(apiLink.."latest.json?show_alternative=1&app_id="..apiKey)
    return connected, res
end

function GetCurrencyNames()
    local connected, res =  RequestUrl(apiLink.."currencies.json?show_alternative=1&app_id="..apiKey)
    return connected, res
end

function command.run(client, ia, cmd, args)
    if args.list then
        return ia:reply{embed=CurrencyEmbed}
    end

    local currencyRates = _G.storageManager:getData("currencyRates")
    local currencyRatesRead = currencyRates:read()

    local currencyNames = _G.storageManager:getData("currencyNames")
    local currencyNamesRead = currencyNames:read()
    
    local hourInSec = 3600
    if currencyRatesRead == nil or currencyRatesRead.lastUpdate < os.time()-hourInSec then
        local success, res = GetCurrencyRates()
        if not success then
            return ia:reply(res, true)
        end
        res = json.parse(res)
        currencyRatesRead = {
            lastUpdate = os.time(),
            rates = res.rates,
            timestamp = res.timestamp
        }
        currencyRates:write(currencyRatesRead)
    end

    local weekInSec = 604800
    if currencyNamesRead == nil or currencyNamesRead.lastUpdate < os.time()-weekInSec then
        local success, res = GetCurrencyNames()
        if not success then
            return ia:reply(res, true)
        end
        currencyNamesRead = {
            lastUpdate = os.time(),
            names = json.parse(res)
        }
        currencyNames:write(currencyNamesRead)
    end

    args = args.convert

    local fromRate = currencyRatesRead.rates[string.upper(args.from)]
    local toRate = currencyRatesRead.rates[string.upper(args.to)]

    if fromRate == nil then
        return ia:reply("`"..args.from.."` is not a valid currency. Please do `/currency list` to find valid currencies.", true)
    end

    if toRate == nil then
        return ia:reply("`"..args.to.."` is not a valid currency. Please do `/currency list` to find valid currencies.", true)
    end

    local fromName = currencyNamesRead.names[string.upper(args.from)] or ""
    if fromName ~= "" then
        fromName = "("..fromName..")"
    end
    local toName = currencyNamesRead.names[string.upper(args.to)] or ""
    if toName ~= "" then
        toName = "("..toName..")"
    end

    local originalAmount = args.amount
    local convertedAmount = originalAmount / fromRate * toRate

    local embed = {
        title = "Currency Conversion",
        description = "Currency rates were taken from https://openexchangerates.org.",
        footer = {
            text = "Currency rates last updated"
        },
        timestamp = os.date("!%Y-%m-%dT%TZ", currencyRatesRead.timestamp),
        fields = {
            {name = "", value=""},
            {
                name = funs.trim("From: "..string.upper(args.from).." "..fromName),
                value = tostring(funs.fancyRound(originalAmount,2))
            },
            {
                name = funs.trim("To: "..string.upper(args.to).." "..toName),
                value = tostring(funs.fancyRound(convertedAmount,2))
            },
            {name = "", value=""}
        }
    }

    print(json.stringify(embed))

    local success, err = ia:reply{embed=embed}

    if not success then
        print(err)
        ia:reply(err + "\n" + json.stringify(embed), true)
    end

end

command.info = {
    name = "currency",
    description = "Command about converting currencies.",
    type = dia.enums.appCommandType.chatInput,
    options = {
        {
            name = "list",
            description = "List of some currencies and their acronyms/abbreviations.",
            type = dia.enums.appCommandOptionType.subCommand,
        },
        {
            name = "convert",
            description = "Convert currencies.",
            type = dia.enums.appCommandOptionType.subCommand,
            options = {
                {
                    name = "amount",
                    description = "The amount of currency you wanna convert.",
                    type = dia.enums.appCommandOptionType.number,
                    required = true
                },
                {
                    name = "from",
                    description = "Currency to convert from.",
                    type = dia.enums.appCommandOptionType.string,
                    required = true
                },
                {
                    name = "to",
                    description = "Currency to convert to.",
                    type = dia.enums.appCommandOptionType.string,
                    required = true
                }
            }
        }
    }
}

CurrencyEmbed = {
    title = "Currency acronyms/abbreviations.",
    description = "A list of most currencies along with their acronyms/abbreviations. When running `/currency convert`, you will need to provide the currencies acronyms/abbreviations, not their full name.",
    fields = {
        {name="",value="",inline=false},
        {name="United States Dollar",value="USD",inline=true},
        {name="Euro",value="EUR",inline=true},
        {name="Japanese Yen",value="JPY",inline=true},
        {name="British Pound Sterling",value="GBP",inline=true},
        {name="Chinese Yuan",value="CNY",inline=true},
        {name="Australian Dollar",value="AUD",inline=true},
        {name="Canadian Dollar",value="CAD",inline=true},
        {name="Swedish Krona",value="SEK",inline=true},
        {name="South Korean Won",value="KRW",inline=true},
        {name="Norwegian Krone",value="NOK",inline=true},
        {name="New Zealand Dollar",value="NZD",inline=true},
        {name="Mexican Peso",value="MXN",inline=true},
        {name="New Taiwan Dollar",value="TWD",inline=true},
        {name="Brazilian Real",value="BRL",inline=true},
        {name="Danish Krone",value="DKK",inline=true},
        {name="Polish Zloty",value="PLN",inline=true},
        {name="Thai Baht",value="THB",inline=true},
        {name="Israeli New Sheqel",value="ILS",inline=true},
        {name="Czech Republic Koruna",value="CZK",inline=true},
        {name="Philippine Peso",value="PHP",inline=true},
        {name="Russian Ruble",value="RUB",inline=true},
        {name="",value="",inline=false},
        {name="More Currencies",value="For a list of all supported currencies, go here: https://docs.openexchangerates.org/reference/supported-currencies",inline=false},
    }
}

return command