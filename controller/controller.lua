-- Import this library
local g = require("gachLib")
--------------------------------------------------------------------------------

-- Create new application
local application = g.gui.application()
local label = g.gui.label(10,10,20,20,"TEST")
application:addChild(label)

application:start()