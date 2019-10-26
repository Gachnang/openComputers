local serialization = require("serialization")
local eventHandler = require("gachLib.eventHandler")
local util = require("gachLib.util")

local gLs = {
  onChange = eventHandler()
}
local doc = {}
local state = nil
--local observers = {}

doc.observe = "function(fn:function(newState:any, oldState:any)):number -- Subscibe the state. Call 'unsubscibe' with returned number to unsubscibe." 
function gLs.subscibe(fn)
--  checkArg(1, fn, "function")
--  observers[#observers+1] = fn
  
--  local f = function() 
--    for key,value in pairs(observers) do 
--      if value == fn then 
--        observers[key] = nil
--        break 
--      end 
--    end
--  end
  
--  return f
  gLs.onChange = gLs.onChange + fn
end

doc.unsubscibe = "function(id:number) -- Unsubscibes the state."
function gLs.unsubscibe(id)
  gLs.onChange = gLs.onChange - id
end

function setStateInternal(newState)
  if type(newState) == "table" then
    if type(newState) == type(state) then
      -- current state also a table ..
      if #newState == 0 then
        -- .. and not an array
        for key,value in pairs(newState) do
          state[key] = value
        end
        return state
      end
    end
  end
  state = newState
  return state
end

doc.setState = "function(newState:any[, overwrite:boolean]):any -- Sets the state. Tables gets merged. Set overwrite to true for no merging." 
function gLs.setState(newState, overwrite)
  local newS = nil
  local oldS = util.deepcopy(state)
  
  if overwrite == nil or overwrite == true then
    newS = setStateInternal(newState)
  else
    state = newState
    newS = state
  end
  
  gLs.onChange(newS, oldS)
  
  return s
end

doc.getState = "function():any -- Gets the state." 
function gLs.getState()
  return state
end

return gLs --require("gachLib.doc")(gLs, doc)