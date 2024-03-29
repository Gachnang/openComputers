local component = require("component")
local event = require("event")
local serialization = require("serialization")
local eventHandler = require("gachLib.type.eventHandler")
local state = require("gachLib.state")

local gLn = {
  event = {
    onDirectoryAdded = eventHandler(),
    onDirectoryRemoved = eventHandler(),
    onPong = eventHandler(),
    onGetStateAnswer = eventHandler(),
  },
  directory = {
    -- [name] = address
  },
  protocol = "gachLib.state",
  --DEBUG
  debug = {}
}
local doc = {
  directory = "-- Table of name and address of computers in network."
}

local private = {
  port = 1,
  eventListener = nil,
  stateTimer = nil,
  stateSubscription = nil,
  stateChanged = false,
  stateSubsciber = {},
  pingWaiter = {
    -- [onPongId] = { waiter = 2, callbcack = func}
  }
}

function private.createPackage(code, targetName, targetAddress, data)
  local packet = {
      code = code,
      source = {
        name = nm.computername,
        address = gLn.nm.modemProxy.address
      },
      target = {
        name = targetName,
        address = targetAddress
      }
    }
  
  if data ~= nil and type(data) ~= "function" then
    packet.data = data
  end
  
  return serialization.serialize({gLn.protocol, packet})
end

function private.messageCheck(message)
  local ret = 0
  if message ~= nil and message.source ~= nil and message.target ~= nil then
    ret = 1
    if message.target.name == "BROADCAST" or message.target.name == nm.computername or message.target.address == gLn.nm.modemProxy.address then
      ret = 2
    end
  end
  return ret
end

function private.onModemMessage(eventName, receiverAddress, senderAddress, port, distance, protocol, message)
  message = serialization.unserialize(message)
  -- DEBUG
  local messageCheck = private.messageCheck(message)
  gLn.debug[#gLn.debug + 1] = {messageCheck, message}
  
  if messageCheck > 0 then
    if gLn.directory[message.source.name] == nil or gLn.directory[message.source.name] ~= message.source.address then
      gLn.directory[message.source.name] = message.source.address
      gLn.event.onDirectoryAdded:trigger(message.source)
    end
    
    if message.code == "di" then 
    -- discovery
      gLn.nm.sendMessage(
        private.port, 
        message.source.address, 
        private.createPackage("dia", message.source.name, message.source.address))
    elseif message.code == "rm" then
    -- computer stoped
      gLn.directory[message.source.name] = nil
      private.stateSubsciber[message.source.name] = nil
      gLn.event.onDirectoryRemoved:trigger(message.source)
    end
    
    if messageCheck > 1 then
      if message.code == "ping" then
      -- ping
        gLn.nm.sendMessage(
          private.port, 
          message.source.address, 
          private.createPackage("pong", message.source.name, message.source.address))
      elseif message.code == "pong" then
      -- pong
        gLn.event.onPong:trigger(message.source)      
      elseif message.code == "gs" then
      -- getState
        gLn.nm.sendMessage(
          private.port, 
          message.source.address, 
          private.createPackage("gsa", message.source.name, message.source.address, state.getState()))
      elseif message.code == "gsa" then
      -- getState answer
        gLn.event.onGetStateAnswer:trigger({source = message.source, state = message.data}) 
      elseif message.code == "ss" then
      -- state subscibe
        private.stateSubsciber[message.source.name] = true
      elseif message.code == "sus" then
      -- state unsubscibe
        private.stateSubsciber[message.source.name] = nil
      end
    end
  end 
end

function private.onTimer()
  -- State
  if private.stateChanged then
    for desName,_ in pairs(private.stateSubsciber) do
      local desAddress = gLn.nameToAddress(desName)
      gLn.nm.sendMessage(
        private.port, 
        desAddress, 
        private.createPackage("gsa", desName, desAddress, state.getState()))
    end
    private.stateChanged = false
  end
  -- Ping
  for onPongId,value in pairs(private.pingWaiter) do
    value.waiter = value.waiter - 1
    if value.waiter <= 0 then
      value.callback(false)
      gLn.event.onPong:remove(onPongId)
      private.pingWaiter[onPongId] = nil
    end
  end
end

doc.getName = "function():boolean -- Discovers computers in network and fills 'directory' with the answers. Return true when sended."
function gLn.discover()
    return gLn.nm.broadcastMessage(private.port, private.createPackage("di", "BROADCAST", "BROADCAST", state.getState()))
end

function gLn.getState(name, callback)
  checkArg(1, name, "string")
  checkArg(2, callback, "function")
  
  local i = gLn.event.onGetStateAnswer:add(function(stateAnswer)
    if stateAnswer.source.name == name then
      gLn.event.onGetStateAnswer:remove(i)
      callback(stateAnswer.state)
    end
  end)
  --------------
  gLn.nm.sendMessage(
    gLn.directory[name], 
    private.port, 
    private.createPackage("gs", name, gLn.directory[name]))
end

doc.subscribeState = "function(name:string[, func:function]):boolean -- Subscribes the state of a computer with given name. Gets state on 'event.onGetStateAnswer' or pass it as parameter func."
function gLn.subscribeState(name, func)
  checkArg(1, name, "string")
  
  if func ~= nil and type(func) == "function" then
    gLn.event.onGetStateAnswer:add(function(message) 
      if message.source.name == name then
        func(message)
      end
    end)
  end
  
  return gLn.nm.sendMessage(
    private.port, 
    gLn.directory[name], 
    private.createPackage("ss", name, gLn.directory[name]))
end

doc.unsubscribeState = "function(name:string):boolean -- Unsubscribes the state of a computer with given name."
function gLn.unsubscribeState(name)
  checkArg(1, name, "string")
  return gLn.nm.sendMessage(
    gLn.directory[name], 
    private.port, 
    private.createPackage("sus", name, gLn.directory[name]))
end

function gLn.ping(name, callback)
  checkArg(1, name, "string")
  checkArg(2, callback, "function")
  
  if func ~= nil and type(func) == "function" then
    local onPongId = gLn.event.onPong:add(function(message)
      if message.source.name == name then
        callback(true)
        gLn.event.onPong:remove(onPongId)
        private.pingWaiter[onPongId] = nil
      end
    end)
    private.pingWaiter[onPongId] = {waiter = 2, callback = callback}
  end
end

doc.nameToAddress = "function(name:string):string -- Gets the address of a computer with given name."
function gLn.nameToAddress(name)
  checkArg(1, name, "string")
  
  return gLn.directory[name]
end

doc.addressToName = "function(address:string):string -- Gets the name of a computer with given address."
function gLn.addressToName(address)
  checkArg(1, address, "string")
  
  for k, v in pairs(gLn.directory) do
    if v == address then
      return k
    end
  end
  return nil
end

doc.getName = "function(name:string[, port:number]):void -- Inits the gachLib.network."
function gLn.init(name, port)    
    gLn.nm.modemProxy.open(private.port)
    
    private.timer = event.timer(5, private.onTimer, math.huge)
    private.stateSubscription = state.subscribe(function(new, old)
      private.stateChanged = true
    end)
    
    gLn.discover()
  end
end

doc.getName = "function():void -- Destroys the gachLib.network like before 'init'."
function gLn.destroy()
    if gLn.nm.modemProxy.isOpen(private.port) then
      gLn.nm.broadcastMessage(private.port, private.createPackage("rm", "BROADCAST", "BROADCAST", state.getState()))
      gLn.nm.modemProxy.close(private.port)
    end
        
    if private.timer ~= nil and type(private.timer) == "number" then
      event.cancel(private.timer)
    end
    
    if private.stateSubscription ~= nil and type(private.stateSubscription) == "number" then 
      state.unsubscribe(private.stateSubscription)
    end  
  end
end

return gLn, gLn.protocol, doc