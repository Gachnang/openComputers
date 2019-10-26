return function()
  local event = {
    i = 0,
    handlers = {}
  }
  event.__index = event
  
  function event:add(func)
    checkArg(1, self, "table")
    checkArg(2, func, "function")
      
    self.i = self.i + 1
    self.handlers[self.i] = func
    return self.i
  end
    
  function event:remove(id)
    checkArg(1, self, "table")
    checkArg(2, id, "number")
  
    self.handlers[id] = nil
  end
    
  function event:trigger(...)  
    checkArg(1, self, "table")   
    for key,value in pairs(self.handlers) do
      self.handlers[key](...)
    end
  end
  
  event = setmetatable(event, {
    __call = function(self, ...)
      self:trigger(...)
      return self
    end,
    __add = function(self, func)
      self:add(func)
      return self
    end,
    __sub = function(self, id)
      self:remove(id)
      return self
    end
  })
  return event
end