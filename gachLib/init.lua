local component=require("component")

local gL = {
  type = require("gachLib.type"),
  state = require("gachLib.state"),
  util = require("gachLib.util")
}

if component.isAvailabel("transposer") then
  gL.transposer = require("gachLib.transposer")
end

if component.isAvailabel("modem") then
  gL.network = require("gachLib.network")  
end

return gL