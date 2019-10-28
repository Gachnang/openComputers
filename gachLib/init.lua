local component=require("component")

local gL = {
  type = require("gachLib.type"),
  state = require("gachLib.state"),
  util = require("gachLib.util")
}

if gL.util.tableCount(component.list("transposer")) > 0  then
  gL.transposer = require("gachLib.transposer")
end

if gL.util.tableCount(component.list("modem")) > 0 then
  gL.network = require("gachLib.network")  
end

if gL.util.tableCount(component.list("gpu")) > 0 then
  gL.gui = require("gachLib.gui")
end 

return gL