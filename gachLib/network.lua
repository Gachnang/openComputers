local component = require("component")
local modem = component.modem
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
    -- name = address
  },
  debug = {}
}
local doc = {
  directory = "-- Table of name and address of computers in network."
}

local private = {
  port = 1,
  computername = nil,
  eventListener = nil,
  stateTimer = nil,
  staeSendTime = 0,
  stateSubsciber = {}
}

function private.createPackage(code, targetName, targetAddress, data)
  local packet = serialization.serialize({
      code = code,
      source = {
        name = private.computername,
        address = modem.address
      },
      target = {
        name = targetName,
        address = targetAddress
      }
    })
  
  if data ~= nil and type(data) ~= "function" then
    packet.data = data
  end
  
  return packet
end

function private.messageCheck(message)
  local ret = 0
  if message ~= nil and message.source ~= nil and message.target ~= nil then
    ret = 1
    if message.target.name == "BROADCAST" or message.target.name == private.computername or message.target.address == modem.address then
      ret = 2
    end
  end
  return ret
end

function private.onMessage(eventName, receiverAddress, senderAddress, port, distance, message)
  message = serialization.unserialize(message)
  gLn.debug[#gLn.debug + 1] = message
  local messageCheck = private.messageCheck(message)
  
  if messageCheck > 0 then
    if gLn.directory[message.source.name] == nil or gLn.directory[message.source.name] ~= message.source.address then
      gLn.directory[message.source.name] = message.source.address
      gLn.event.onDirectoryAdded(message.source)
    end
    
    if message.code == "di" then 
    -- discovery
      modem.send(
        message.address, 
        private.port, 
        private.createPackage("dia", message.source.name, message.source.address))
    elseif message.code == "rm" then
    -- computer stoped
      gLn.directory[message.source.name] = nil
      gLn.event.onDirectoryRemoved(message.source)
    end
    
    if messageCheck > 1 then
      if message.code == "ping" then
      -- ping
        modem.send(
          message.source.address, 
          private.port, 
          private.createPackage("pong", message.source.name, message.source.address))
      elseif message.code == "pong" then
      -- pong
        gLn.event.onPong(message.source)      
      elseif message.code == "gs" then
      -- getState
        modem.send(
          message.source.address, 
          private.port, 
          private.createPackage("gsa", message.source.name, message.source.address, state.getState()))
      elseif message.code == "gsa" then
      -- getState answer
        gLn.event.onGetStateAnswer({source = message.source, state = message.data}) 
      elseif message.code == "ss" then
      -- state subscibe
        private.stateSubsciber[message.source.name] = true
        modem.send(
          message.source.address, 
          private.port, 
          private.createPackage("gsa", message.source.name, message.source.address, state.getState()))
      elseif message.code == "sus" then
      -- state unsubscibe
        private.stateSubsciber[message.source.name] = nil
      end
    end
  end 
end

function private.onStateTimer()
  for name,_ in pairs(private.stateSubsciber) do
    local desAddress = gLn.nameToAddress(name)
    modem.send(
        desAddress, 
        private.port, 
        private.createPackage("gsa", name, desAddress, state.getState()))
  end
end

doc.getName = "function():boolean -- is gachLib.network inizialized?"
function gLn.isInit()
  return private.computername ~= nil
end

doc.getName = "function():string -- Gets the computername."
function gLn.getName()
  return private.computername
end

doc.getName = "function():boolean -- Discovers computers in network and fills 'directory' with the answers. Return true when sended."
function gLn.discover()
  if gLn.isInit() then
    return modem.broadcast(private.port, serialization.serialize({
      code = "di",
      source = {
        name = private.computername,
        address = modem.address
      },
      target = {
        name = "BROADCAST"
      }
    }))
  end
  return false
end

doc.subscibeState = "function(name:string):boolean -- Subscribes the state of a computer with given name. Gets state on 'event.onGetStateAnswer'."
function gLn.subscibeState(name)
  return modem.send(
    gLn.directory[name], 
    private.port, 
    private.createPackage("ss", name, gLn.directory[name], state.getState()))
end

doc.unsubscibeState = "function(name:string):boolean -- Unsubscribes the state of a computer with given name."
function gLn.unsubscibeState(name)
  return modem.send(
    gLn.directory[name], 
    private.port, 
    private.createPackage("sus", name, gLn.directory[name], state.getState()))
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
  if gLn.isInit() == false then
    checkArg(1, name, "string")
    private.computername = name
  
    if port ~= nil and type(port) == "number" then
      private.port = port
    end  
    
    modem.open(private.port)
    modem.setWakeMessage("WakeUp_" .. private.computername)
    private.eventListener = event.register("modem_message", private.onMessage, math.huge)
    private.stateTimer = event.timer(5, private.onStateTimer, math.huge)
    
    gLn.discover()
  end
end

doc.getName = "function():void -- Destroys the gachLib.network like before 'init'."
function gLn.destroy()
  if gLn.isInit() then
    if modem.isOpen(private.port) then
      modem.broadcast(private.port, serialization.serialize({
        code = "rm",
        source = {
          name = private.computername,
          address = modem.address
        },
        target = {
          name = "BROADCAST"
        }
      }))
      modem.close(private.port)
    end
    
    if private.eventListener ~= nil and type(private.eventListener) == "number" then
      event.cancel(private.eventListener)
    end
    
    if private.stateTimer ~= nil and type(private.stateTimer) == "number" then
      event.cancel(private.stateTimer)
    end
    
    private.computername = nil
    
  end
end

return gLn, doc