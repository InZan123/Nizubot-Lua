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
storageManager.pendingSaving = {}

function storageManager:createData(key, defaultData, registered)
    if not key then
        return error("Please provide a key!!!",2)
    end
    local data = {
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
            self.storageManager.pendingSaving[self.key] = self
            if self.registered == false then
                self.registered = true
                self.storageManager:getTable(self.key).data = self
            end
        end,
    
        delete = function(self)
            self.storageManager:deleteData(self.key)
        end,
    
        isSaved = function(self)
            return self.saved
        end
    }
    data.key = key
    data.data = defaultData
    data.registered = registered or false
    return data
end

function storageManager:getTable(key)
    local keys={}

    for str in string.gmatch(key, "([^/]+)") do
        table.insert(keys, str)
    end

    local current = self.loadedData

    for i, v in ipairs(keys) do
        if v == "data" then
            error('"data" cannot be a part of the key!!!',2)
            return {}
        end
        local data = current[v]
        if not data then
            data = {}
            current[v] = data
            current = data
        else
            current = data
        end
    end
    return current
end

function storageManager:removeTable(key)
    local keys={}

    for str in string.gmatch(key, "([^/]+)") do
        table.insert(keys, str)
    end

    local current = self.loadedData

    for i, v in ipairs(keys) do
        if v == "data" then
            error('"data" cannot be a part of the key!!!',2)
            return
        end

        if i == #keys then
            current[v] = nil
            return
        end

        local data = current[v]
        if not data then
            data = {}
            current[v] = data
            current = data
        else
            current = data
        end
    end
end

function storageManager:getData(key, defaultData)

    local keyTable = self:getTable(key)

    if keyTable.data then
        return keyTable.data
    end

    local filePath = self:getFullPath(key)

    if not fs.stat(filePath) then
        return self:createData(key, defaultData, false)
    end

    local file = fs.open(filePath, "r")
    local data = fs.read(file)
    fs.close(file)
    local dataTable = self:createData(key, json.parse(data), true)
    keyTable.data = dataTable
    return dataTable
end

function storageManager:saveAllData()
    local savedKeys = {}
    for key, data in pairs(self.pendingSaving) do

        print("Saving "..key)

        local filePath = self:getFullPath(key)
        local fileDirectory = self:getDirectory(key)
        if not fs.stat(fileDirectory) then
            fs.mkdirp(fileDirectory)
        end

        local file = fs.open(filePath, "w")
        fs.write(file, json.stringify(data:read()))
        fs.close(file)
        data.saved = true
        table.insert(savedKeys, key)
    end

    for i, k in pairs(savedKeys) do
        self.pendingSaving[k] = nil
    end
end

function storageManager:deleteData(key)
    --remove directory and file
    fs.rmrf(self.filePath.."/"..key)
    fs.rmrf(self:getFullPath(key))
    self:removeTable(key)
end

local captionFolder = "data/generated/caption/"
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

        for file in fs.scandir(captionFolder) do

            local mTime = fs.stat(captionFolder .. "/" .. file.name).mtime.sec

            if now - mTime > 60 then
                fs.unlink(captionFolder .. "/" .. file.name)
            end
        end

		timer.sleep(1000)
	end
end)()

return storageManager