local container = require("gachLib.gui.container")
local buffer = require("gachLib.gui.doubleBuffer")
local event = require("event")
local thread = require("thread")
local computer = require("computer")

local function applicationDraw(appl, delta, force)
	appl.draw.drawContainer(appl, delta)
	buffer.drawChanges(force)
end

local function applicationEventListenerScreen(type, screenAddress, x, y, button, playerName)
    local eventData = {
        type = type, 
        screenAddress = screenAddress, 
        x = x, 
        y = y, 
        button = button, 
        playerName = playerName}
end

local function applicationEventListenerTouch(screenAddress, x, y, button, playerName)
    applicationEventListenerScreen("touch", screenAddress, x, y, button, playerName)
end

local function applicationEventListenerDrag(screenAddress, x, y, button, playerName)
    applicationEventListenerScreen("drag", screenAddress, x, y, button, playerName)
end

local function applicationEventListenerDrop(screenAddress, x, y, button, playerName)
    applicationEventListenerScreen("drop", screenAddress, x, y, button, playerName)
end

local function applicationEventListenerScroll(screenAddress, x, y, button, playerName)
    applicationEventListenerScreen("scroll", screenAddress, x, y, button, playerName)
end

local function applicationDrawThread(appl)
    local time = computer.uptime()
    appl.draw.draw(appl, 0, true)
    
    local delta = 0
    local fpsCounter = 1
    local fpsDelta = 0
    local fpsSleep = 0
    
    while appl.running do
        os.sleep(fpsSleep)
        delta = time - computer.uptime()
        time = computer.uptime()       
                
        appl.draw.draw(appl, delta, false)

        fpsDelta = fpsDelta + delta
        fpsCount = fpsCount + 1
        if fpsDelta > 5 then
            appl.draw.fps = fpsCount / fpsDelta
            
            if appl.draw.fps > 30 then
                fpsSleep = fpsSleep + 0.05
            elseif appl.draw.fps < 20 and fpsSleep > 0 then
                fpsSleep = fpsSleep - 0.05
            end
            
            fpsCounter = 0
            fpsDelta = 0
        end
    end
end

local function applicationStart(appl)
    appl.running = true
    
    appl.event.listenerTouch = event.listen("touch", applicationEventListenerScreen)
    appl.event.listenerDrag = event.listen("drag", applicationEventListenerDrag)
    appl.event.listenerDrop = event.listen("drop", applicationEventListenerDrop)
    appl.event.listenerScroll = event.listen("scroll", applicationEventListenerScroll)
    
    appl.thread = thread.create(applicationDrawThread, appl)
    
end

local function applicationStop(appl)
    appl.running = false
    
    thread.waitForAll({appl.thread})
    
    event.cancel(appl.event.listenerTouch)
    event.cancel(appl.event.listenerDrag)
    event.cancel(appl.event.listenerDrop)
    event.cancel(appl.event.listenerScroll)
end

return function()
    local appl = container(1, 1, buffer.getWidth(), buffer.getHeight())
    appl.type = appl.type .. ".application"
    
    appl.event.listenerScreen = 0.1
    
    appl.draw.drawContainer = appl.draw.draw
    appl.draw.draw = applicationDraw
    appl.draw.fps = 0
    
    appl.running = false
    application.start = applicationStart
	application.stop = applicationStop
    
    return appl
end