-- Import this library
local GUI = require("GUI")
-- We will also need downloaded double buffering library to render rectangles
local buffer = require("doubleBuffering")

--------------------------------------------------------------------------------

-- Create new application
local application = GUI.application()

-- BackGround
application:addChild(GUI.panel(1, 1, application.width, application.height, 0x2D2D2D))
 
-- Add menu-list -> Create horizontally oriented list
local horizontalList = application:addChild(GUI.list(34, 2, 100, 3, 2, 0, 0xE1E1E1, 0x4B4B4B, 0xE1E1E1, 0x4B4B4B, 0x696969, 0xFFFFFF, true))
horizontalList:setDirection(GUI.DIRECTION_HORIZONTAL)
horizontalList:setAlignment(GUI.ALIGNMENT_HORIZONTAL_CENTER, GUI.ALIGNMENT_VERTICAL_TOP)
horizontalList:addItem("Übersicht").onTouch = function()
	selectTab(1)
end
horizontalList:addItem("Power").onTouch = function()
	selectTab(2)
end
horizontalList:addItem("Woot").onTouch = function()
	selectTab(3)
end
horizontalList:addItem("Debug").onTouch = function()
	selectTab(4)
end

function selectTab(id)
  GUI.alert("SelectTab " .. id)
end
--------------------------------------------------------------------------------
-- power
local chart = GUI.chart(2, 2, 0.9 * application.width, application.height / 4, 0xEEEEEE, 0xAAAAAA, 0x888888, 0xFFDB40, 0.25, 0.25, "s", "t", true, {})
for i = 1, 100 do
	table.insert(chart.values, {i, math.random(0, 80)})
end
--------------------------------------------------------------------------------

application:draw(true)
application:start()