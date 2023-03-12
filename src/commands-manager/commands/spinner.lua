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

    local spinForce = math.random(0,120)
    local spinReduction = 1
    local waitTime = 1000

    local events = {
        wind = {
            probability=0.05,
            run=function(self, events)
                self.probability = self.probability*0.1
                events.sandstorm.probability = events.sandstorm.probability*3
                spinForce = spinForce*2 + 20
            end,

            message = "A burst of wind came and spun the spinner even faster!",
            subMessages = {
                "*How is there wind? I thought we were inside?*",
                "*Such a nice breeze!*",
                "*I hope this isn't a sandstorm.*",
            }
        },
        sandstorm = {
            probability=0.01,
            run=function(self, events)
                self.probability = self.probability*0.01
                spinReduction = spinReduction*3
            end,

            message = "There's a sandstorm! Some sand grains came into the bearing making it spin much worse.",
            subMessages = {
                "*Aw man... Now my spinner is ruined!*",
                "*Aah! I got sand in my eye!*"
            }
        },
        earthquake = {
            probability=0.025,
            run=function(self, events)
                self.probability = self.probability * 0.01
                spinForce = spinForce + math.random(-20,20)
            end,

            message = "Earthquake! The spin of the spinner seems to be affected by it.",
            subMessages = {
                "*The ground is shaking!*"
            }
        },
        gold = {
            probability=0.0075,
            run=function(self, events)
                self.probability = 0
                spinReduction = spinReduction * 0.25
            end,

            message = "A magic wizard appeared! They casted a spell which turned your spinner into pure gold.",
            subMessages = {
                "*How kind of them!*",
                "*Fancy.*",
                "*I should sell this later.*"
            }
        },
        timeUp = {
            probability=0.005,
            run=function(self, events)
                self.probability = 0
                waitTime = waitTime*1.5
                events.timeDown.message = "The scientist managed to slow down time again! Things will now happen at a normal rate."
                events.timeDown.probability = events.timeDown.probability*10
            end,

            message = "A crazy scientist accidentally sped up time! Things will now happen faster.",
        },
        timeDown = {
            probability=0.005,
            run=function(self, events)
                self.probability = 0
                waitTime = waitTime/1.5
                events.timeUp.message = "The scientist managed to speed up time again! Things will now happen at a normal rate."
                events.timeUp.probability = events.timeUp.probability*10
            end,

            message = "A crazy scientist accidentally slowed down time! Things will now happen slower.",
        },
        drop = {
            probability=0.0005,
            run=function(self, events)
                self.probability = 0
                spinForce = spinForce * 0.001
            end,

            message = "You accidentally dropped your spinner.",
            subMessages = {
                "*Oops I dropped it.*"
            }
        }
    }

    local currentMsg = "[insert niko spinning fidget spinner here] You are now spinning your spinner..."
    ia:reply(currentMsg)
    local msg = ia:getReply()
    local startTime = os.time()
        
    timer.sleep(waitTime)

    while spinForce > 0 do
        spinForce = spinForce - spinReduction
        local randomNumber = math.random()
        local totalProbability = 0
        for k,v in pairs(events) do
            totalProbability = totalProbability + (v.probability or 0)
            if randomNumber < totalProbability then
                v:run(events)
                currentMsg = currentMsg.."\n\n["..os.time()-startTime.."s] "..v.message
                if v.subMessages and next(v.subMessages) then
                    currentMsg = currentMsg.."\n"..v.subMessages[math.random(1,#v.subMessages)]
                end
                msg:update{content=currentMsg}
                break
            end
        end

        timer.sleep(1000)
    end
    
    local spinDuration = os.time()-startTime
    ia:reply(ia.user.mentionString.."'s spinner spun for a total of "..spinDuration.." seconds!")
end

command.info = {
    name = "spinner",
    description = "Spin a fidget spinner!",
    type = dia.enums.appCommandType.chatInput
}

return command