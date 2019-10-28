local buffer = require("gachLib.gui.doubleBuffer")

local function controlDraw(control, delta)
    checkArg(1, control, "table")
    checkArg(2, delta, "number")
  
    if not control.hidden then
        control.draw.drawBackground(control, delta)
    end
    
    return control
end

local function controlDrawBackground(control, delta)
    checkArg(1, control, "table")
    checkArg(2, delta, "number")
    
    if control.color.background ~= nil then
		buffer.drawRectangle(control.x, control.y, control.width, control.height, control.color.background)
	end
    
    return control
end

local function eventHanlder(control, eventData)
  if type(control.event[eventData.type]) == "function" then
    return control.event[eventData.type](control, eventData)
  end
  return control
end

local function getTopParent(control)
    local ret = control
    while ret.parent ~= nil do
        ret = control.parent
    end
    return ret
end

return function(x, y, width, height)
    local draw = setmetatable({
        draw = controlDraw,
        drawBackground = controlDrawBackground
    },{
        __call = function(control, delta)
            control.draw.draw(control, delta)
            return self
        end
    })

    local event = setmetatable({
        event = eventHanlder,
        -- Screen
        screen_resized = nil,   -- screenAddress: string, newWidth: number, newHeight: number
        touch = nil,            -- screenAddress: string, x: number, y: number, button: number, playerName: string
        drag = nil,             -- screenAddress: string, x: number, y: number, button: number, playerName: string
        drop = nil,             -- screenAddress: string, x: number, y: number, button: number, playerName: string
        scroll = nil,           -- screenAddress: string, x: number, y: number, direction: number, playerName: string
        walk = nil,             -- screenAddress: string, x: number, y: number[, playerName: string]
        -- Keyboard
        key_down = nil,         -- keyboardAddress: string, char: number, code: number, playerName: string
        key_up = nil,           -- keyboardAddress: string, char: number, code: number, playerName: string
        clipboard = nil         -- keyboardAddress: string, value: string, playerName: string
        
    },{
        __call = function(control, eventData)
            control.event.event(control, eventData)
            return self
        end
    })   

	local control = {
        type = "control",
        -- x = absolute position -> can be changed by parent (container)
		x = x,
        -- localX = relative position -> to move control, change this one!
        localX = x,
		y = y,
        localY = y,
        
		width = width,
		height = height,
        
        hidden = false,
        disabled = false,
        
        parent = nil,
        getTopParent = getTopParent,
        
        color = {
          background = nil
        },
        
        event = event,
        draw = draw
	}
    control.__index = control
    event.__index = control
    draw.__index = control
    
    return control
end