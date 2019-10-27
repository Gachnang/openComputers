-- Import this library
local GUI = require("GUI")
-- We will also need downloaded double buffering library to render rectangles
local buffer = require("doubleBuffering")

--------------------------------------------------------------------------------

-- Create new application
local application = GUI.application()

-- BackGround
application:addChild(GUI.panel(1, 1, application.width, application.height, 0x2D2D2D))

-- Add an layout with 1x4 grid size to application
local layout = application:addChild(GUI.layout(1, 1, application.width, application.height, 1, 4))


-- power
local chart = GUI.chart(2, 2, 100, 30, 0xEEEEEE, 0xAAAAAA, 0x888888, 0xFFDB40, 0.25, 0.25, "s", "t", true, {})
for i = 1, 100 do
	table.insert(chart.values, {i, math.random(0, 80)})
end
layout:setPosition(1, 1, layout:addChild(chart))
 -- woot
layout:setPosition(1, 2, layout:addChild(GUI.button(1, 1, 26, 3, 0xEEEEEE, 0x000000, 0xAAAAAA, 0x0, "WOOT")))
 
 -- ?
layout:setPosition(1, 3, layout:addChild(GUI.button(1, 1, 26, 3, 0xEEEEEE, 0x000000, 0xAAAAAA, 0x0, "Button 3")))
 
 -- Spacestation
layout:setPosition(1, 4, layout:addChild(GUI.button(1, 1, 26, 3, 0xEEEEEE, 0x000000, 0xAAAAAA, 0x0, "Button 4"))) 

--------------------------------------------------------------------------------

application:draw(true)
application:start()