local dia = require('discordia')
local timer = require('timer')

local command = {}

command.spinning = {}

function command.run(client, ia, cmd, args)
    if command.spinning[ia.user.id] then
        return ia:reply("You are already spinning a spinner!", true)
    end
    local co = coroutine.create(SpinSpinner)
    coroutine.resume(co, ia)
end

function SpinSpinner(ia)
    local currentMsg = "[insert niko spinning fidget spinner here] You are now spinning your spinner..."
    ia:reply(currentMsg)
    local msg = ia:getReply()
    local startTime = os.time()
    local spinForce = math.random(1,60)

    while spinForce > 0 do
        spinForce = spinForce - 1
        timer.sleep(1000)
    end
    
    local spinDuration = os.time()-startTime
    currentMsg = "And it stopped. It spun for a total of "..spinDuration.." seconds!"
    ia:reply{content = currentMsg}
end

command.info = {
    name = "spinner",
    description = "Spin a fidget spinner!",
    type = dia.enums.appCommandType.chatInput
}

return command