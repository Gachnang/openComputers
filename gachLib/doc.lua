local serialization = require("serialization")

return function(mod, doc)
  checkArg(1, mod, "table")
  checkArg(2, doc, "table")
  
  --local old = [[
    return setmetatable(mod, {
      __tostring = function(self)
        local result = "{\n"
        for k, v in pairs(self) do
        
          if doc[k] ~= nil then
            if type(self[k]) == "function" then
              result = result .. " " .. k .. " : " .. doc[k]
            else
              result = result .. " " .. k .. " = " .. serialization.serialize(self[k]) .. " : " .. doc[k]
            end
          elseif type(self[k]) == "function" then
            result = result .. " " .. k .. " = function"
          else
            result = result .. " " .. k .. " = " .. serialization.serialize(self[k])
          end
          result = result .. ",\n"
        end
        
        result = string.sub(result,0,-3) .. "\n}"
        return result
      end  
    })--]]
end
