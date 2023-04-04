local storageManager = {}

local json = require('json')
local timer = require('timer')
local funs = require("src/functions")

local fs = require("coro-fs")

storageManager.filePath = "./data"

function storageManager:getFullPath(key)
    return self.filePath..'/'..key..'.json'
end

function storageManager:getDirectory(key)
    local t={}
    for str in string.gmatch(key, "([^/]+)") do
        table.insert(t, str)
    end
    table.remove(t, t.length)
    return self.filePath..'/'..table.concat(t, "/")
end

storageManager.loadedData = {}

storageManager.dataTemplate = {
    saved = true,
    registered = false,
    storageManager = storageManager,
    data = nil,
    key = nil,

    read = function(self)
        return self.data
    end,

    write = function(self, newData)
        self.data = newData
        self.saved = false
        if self.registered == false then
            self.registered = true
            self.storageManager.loadedData[self.key] = self
        end
    end,

    delete = function(self)
        self.storageManager:deleteData(self.key)
    end,

    isSaved = function(self)
        return self.saved
    end
}

function storageManager:cloneTemplate(key, defaultData, registered)
    local copy = {}
    for orig_key, orig_value in pairs(self.dataTemplate) do
        copy[orig_key] = orig_value
    end
    copy.key = key
    copy.data = defaultData
    copy.registered = registered or false
    return copy
end

function storageManager:getData(key, defaultData)
    local dataTable = self.loadedData[key]
    if dataTable ~= nil then
        return dataTable
    end

    local filePath = self:getFullPath(key)

    if not fs.stat(filePath) then
        return self:cloneTemplate(key, defaultData, false)
    end

    local file = fs.open(filePath, "r")
    local data = fs.read(file)
    fs.close(file)
    dataTable = self:cloneTemplate(key, json.parse(data), true)
    self.loadedData[key] = dataTable
    return dataTable
end

function storageManager:saveAllData()
    for key, data in pairs(self.loadedData) do

        if data:isSaved() then goto continue end

        print("Saving "..key)

        local filePath = self:getFullPath(key)
        local fileDirectory = self:getDirectory(key)
        if not fs.stat(fileDirectory) then
            funs.createDirRecursive(fileDirectory)
        end

        local file = fs.open(filePath, "w")
        fs.write(file, json.stringify(data:read()))
        fs.close(file)
        data.saved = true

        ::continue::
    end
end

function storageManager:deleteData(key)
    local successDirectory = os.execute("rm -r "..self.filePath.."/"..key)
    local successFile = os.execute("rm -r "..self:getFullPath(key))
    self.loadedData[key] = nil
end

local imagesFolder = "data/downloads/images/"

coroutine.wrap(function()
	while true do
        storageManager:saveAllData()

        local now = os.time()

        for file in fs.scandir(imagesFolder) do

            local mTime = fs.stat(imagesFolder .. "/" .. file.name).mtime.sec

            if now - mTime > 60 then
                fs.unlink(imagesFolder .. "/" .. file.name)
            end
        end

		timer.sleep(1000)
	end
end)()

return storageManager