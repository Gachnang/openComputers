local component = require("component")
local computer = require("computer")
local serialization = require("serialization")

local DroneController = {
  comport = 22,
  dronePos = {dx=0,dy=0,dz=0},
  computer = {},
  drone = {},
  inv = {},
  usr = {}
}

function DroneController.sendCommand(command, timeout)
  checkArg(1, command, "string")
  
  if timeout == nil then
    timeout = 10
  end
  
  if not component.modem.isOpen(DroneController.comport) then
    component.modem.open(DroneController.comport)
  end

  component.modem.broadcast(DroneController.comport, command)
    
  local senderAddr = component.modem.address
  while senderAddr == component.modem.address do
    local signalName, recieverAddr, senderAddr, port, range, payload, param = computer.pullSignal(10)
  
    if signalName == "modem_message" and senderAddr ~= component.modem.address then
      return serialization.unserialize(payload)
    elseif signalName == nil then
      return sendCommand(command)  
    end
  end
end

function DroneController.sendCommandWrapper(command, timeout)
  local com = DroneController.sendCommand(command, timeout)
  if com.success then
    return com.message
  else
    error("ERROR from Drone:\n" .. com.message)
  end
end

function DroneController.drone.move(dx, dy, dz, wait)
  if dx == nil then
    dx = 0
  elseif dy == nil then
    dy = 0
  elseif dz == nil then
    dz = 0
  elseif wait == nil then
    wait = 1
  end

  DroneController.dronePos = DroneController.sendCommandWrapper("move(" .. 
      dx .. "," ..
      dy .. "," ..
      dz .. "," ..
      wait .. ")")
      
  return DroneController.dronePos
end

function DroneController.getPos()
  DroneController.dronePos = DroneController.sendCommandWrapper("getPos()")
  return DroneController.dronePos
end

----- computer
function DroneController.computer.address() return DroneController.sendCommandWrapper("computer.address()") end
function DroneController.computer.freeMemory() return DroneController.sendCommandWrapper("computer.freeMemory()") end
function DroneController.computer.totalMemory() return DroneController.sendCommandWrapper("computer.totalMemory()") end
function DroneController.computer.energy() return DroneController.sendCommandWrapper("computer.energy()") end
function DroneController.computer.maxEnergy() return DroneController.sendCommandWrapper("computer.maxEnergy()") end
function DroneController.computer.energyPercent() return DroneController.sendCommandWrapper("computer.energy() / computer.maxEnergy()") end
function DroneController.computer.uptime() return DroneController.sendCommandWrapper("computer.uptime()") end
function DroneController.computer.shutdown(reboot) return DroneController.sendCommandWrapper("computer.shutdown(" .. serialization.serialize(reboot) .. ")") end
----- drone
--- Base Methods
function DroneController.drone.getStatusText() return DroneController.sendCommandWrapper("drone.getStatusText()") end
function DroneController.drone.setStatusText(value) return DroneController.sendCommandWrapper("drone.setStatusText(" .. serialization.serialize(value) ..")") end
function DroneController.drone.getOffset() return DroneController.sendCommandWrapper("drone.getOffset()") end
function DroneController.drone.getVelocity() return DroneController.sendCommandWrapper("drone.getVelocity()") end
function DroneController.drone.getMaxVelocity() return DroneController.sendCommandWrapper("drone.getMaxVelocity()") end
function DroneController.drone.getAcceleration() return DroneController.sendCommandWrapper("drone.getAcceleration()") end
function DroneController.drone.setAcceleration(value) return DroneController.sendCommandWrapper("drone.setAcceleration(" .. value .. ")") end
function DroneController.drone.name() return DroneController.sendCommandWrapper("drone.name()") end
function DroneController.drone.swing(side) return DroneController.sendCommandWrapper("drone.swing(" .. side .. ")") end
function DroneController.drone.use(side, sneaky, duration) return DroneController.sendCommandWrapper("drone.use(" .. side .. "," .. serialization.serialize(sneaky) .. "," .. serialization.serialize(duration) .. ")") end
function DroneController.drone.place(side, sneaky) return DroneController.sendCommandWrapper("drone.place(" .. side .. "," .. serialization.serialize(sneaky) .. ")") end
function DroneController.drone.getLightColor() return DroneController.sendCommandWrapper("drone.getLightColor()") end
function DroneController.drone.setLightColor(value) return DroneController.sendCommandWrapper("drone.setLightColor(" .. value .. ")") end

--- Internal Inventory Methods
function DroneController.drone.inventorySize() return DroneController.sendCommandWrapper("drone.inventorySize()") end
function DroneController.drone.select(slot) return DroneController.sendCommandWrapper("drone.select(" .. serialization.serialize(slot) ..")") end
function DroneController.drone.count(slot) return DroneController.sendCommandWrapper("drone.count(" .. serialization.serialize(slot) ..")") end
function DroneController.drone.space(slot) return DroneController.sendCommandWrapper("drone.space(" .. serialization.serialize(slot) ..")") end
function DroneController.drone.compareTo(otherSlot) return DroneController.sendCommandWrapper("drone.compareTo(" .. otherSlot ..")") end
function DroneController.drone.transferTo(toSlot, amount) return DroneController.sendCommandWrapper("drone.transferTo(" .. toSlot .."," .. serialization.serialize(amount) .. ")") end
function DroneController.drone.tankCount() return DroneController.sendCommandWrapper("drone.tankCount()") end
function DroneController.drone.selectTank(tank) return DroneController.sendCommandWrapper("drone.selectTank(" .. tank ..")") end
function DroneController.drone.tankLevel(tank) return DroneController.sendCommandWrapper("drone.tankLevel(" .. serialization.serialize(tank) ..")") end
function DroneController.drone.tankSpace(tank) return DroneController.sendCommandWrapper("drone.tankSpace(" .. serialization.serialize(tank) ..")") end
function DroneController.drone.compareFluidTo(tank) return DroneController.sendCommandWrapper("drone.compareFluidTo(" .. slot ..")") end
function DroneController.drone.transferFluidTo(tank, count) return DroneController.sendCommandWrapper("drone.transferFluidTo(" .. slot .."," ..  serialization.serialize(count) .. ")") end

--- External Inventory Methods
function DroneController.drone.detect(side) return DroneController.sendCommandWrapper("drone.detect(" .. side .. ")") end
function DroneController.drone.compareFluid(side) return DroneController.sendCommandWrapper("drone.compareFluid(" .. side .. ")") end
function DroneController.drone.drain(side, count) return DroneController.sendCommandWrapper("drone.drain(" .. side .. "," .. serialization.serialize(count) .. ")") end
function DroneController.drone.fill(side, count) return DroneController.sendCommandWrapper("drone.fill(" .. side .. "," .. serialization.serialize(count) .. ")") end
function DroneController.drone.compare(side, fuzzy) return DroneController.sendCommandWrapper("drone.compare(" .. side .. "," .. serialization.serialize(fuzzy) .. ")") end
function DroneController.drone.drop(side, count) return DroneController.sendCommandWrapper("drone.drop(" .. side .. "," .. serialization.serialize(count) .. ")") end
function DroneController.drone.suck(side, count) return DroneController.sendCommandWrapper("drone.suck(" .. side .. "," .. serialization.serialize(count) .. ")") end

----- inv
function DroneController.inv.getInventorySize(side) return DroneController.sendCommandWrapper("inv.getInventorySize(" .. side .. ")") end
function DroneController.inv.getStackInSlot(side, slot) return DroneController.sendCommandWrapper("inv.getStackInSlot(" .. side .. "," .. slot .. ")") end
function DroneController.inv.getStackInInternalSlot(slot) return DroneController.sendCommandWrapper("inv.getStackInInternalSlot(" .. slot .. ")") end
function DroneController.inv.dropIntoSlot(side, slot, count) return DroneController.sendCommandWrapper("inv.dropIntoSlot(" .. side .. "," .. slot .. "," .. serialization.serialize(count) .. ")") end
function DroneController.inv.suckFromSlot(side, slot, count) return DroneController.sendCommandWrapper("inv.suckFromSlot(" .. side .. "," .. slot .. "," .. serialization.serialize(count) .. ")") end
function DroneController.inv.equip() return DroneController.sendCommandWrapper("inv.equip()") end
function DroneController.inv.store(side, slot, dbAddress, dbSlot) return DroneController.sendCommandWrapper("inv.store(" .. side .. "," .. slot .. "," .. dbAddress .. "," .. dbSlot .. ")") end
function DroneController.inv.storeInternal(slot, dbAddress, dbSlot) return DroneController.sendCommandWrapper("inv.storeInternal(" .. slot .. "," .. dbAddress .. "," .. dbSlot .. ")") end
function DroneController.inv.compareToDatabase(slot, dbAddress, dbSlot) return DroneController.sendCommandWrapper("inv.compareToDatabase(" .. slot .. "," .. dbAddress .. "," .. dbSlot .. ")") end
function DroneController.inv.compareStacks(side, slotA, slotB) return DroneController.sendCommandWrapper("inv.compareStacks(" .. side .. "," .. slotA .. "," .. slotB .. ")") end
function DroneController.inv.getSlotMaxStackSize(side, slot) return DroneController.sendCommandWrapper("inv.getSlotMaxStackSize(" .. side .. "," .. slot .. ")") end
function DroneController.inv.getSlotStackSize(side, slot) return DroneController.sendCommandWrapper("inv.getSlotStackSize(" .. side .. "," .. slot ..")") end

----- usr
function DroneController.usr.addCommand(commandName, func)
  checkArg(1, commandName, "string")
  checkArg(2, func, "string")

  DroneController.usr[commandName] = function(...) 
    local command = "usr." .. commandName .. "("
    for i,v in ipairs(arg) do
      command = command .. serialization.serialize(v)
      if i < #arg then command = command .. "," end
    end
    command = command .. ")"
    
    return DroneController.sendCommandWrapper(command)
  end
  
  DroneController.sendCommandWrapper([[(
    function()
      if usr == nil then user = {} end
      usr.]] .. commandName .. " = " .. func .. [[
    end
  )()]])
end

--- Init
return DroneController