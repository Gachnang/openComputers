local unicode = require("unicode")
local control = require("gachLib.gui.control")
local buffer = require("gachLib.gui.doubleBuffer")

local function labelDraw(label, delta)
    checkArg(1, label, "table")
    checkArg(2, delta, "number")
  
    if not label.hidden then
        label.draw.drawBackground(label, delta)
        label.draw.foreBackground(label, delta)
    end
    
    return label
end

local function labelDrawForeground(label, delta)
    checkArg(1, label, "table")
    checkArg(2, delta, "number")
  
    buffer.drawText(
        math.floor(label.x + label.width / 2 - unicode.len(label.text) / 2),
        math.floor(label.y + label.height / 2), 
        label.color.foreground, 
        label.text)
    
    return label
end

return function(x, y, width, height, text, foreground)
	local label = control(x, y, width, height)
    label.type = label.type .. ".label"
    
	label.text = text or "LABEL"
    label.color.foreground = foreground or 0xFFFFFF
    
    label.draw.foreBackground = labelDrawForeground
    
	return label
end