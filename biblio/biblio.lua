-- import
os = require("os")
serialization = require("serialization")

bN = require("biblioNavigation")
dC = require("droneController")

enchantments = {
  "Decay"
}

enchToMap = {}

function populateEnchToMap()
  enchToMap = {}
  
  print("do enchToMap:")
  
  for i=1,#bN.map,1 do
    if bN.map[i] ~= nil and bN.map[i].enchantment ~= nil then
      enchToMap[bN.map[i].enchantment] = i
    end
  end
  
  print(serialization.serialize(enchToMap))
end

function foreachShelf(func)
  for i=17,#enchToMap,1 do
    local pos = enchToMap[i]
    local orientation = bN.map[pos].orientation
    local side = bN.map[pos].chest
    
    bN.moveTo(pos, 1)
    func(pos, 2, side)
    
    bN.moveLevel(orientation,1,1)
    func(pos, 1, side)
    
    bN.moveLevel(orientation,3,1)
    func(pos, 3, side)
    
    bN.moveLevel(orientation,2,0)
    
    if dC.computer.energyPercent() < 0.4 then
      bN.moveTo(1)
      while dC.computer.energyPercent() < 0.95 do
        os.sleep(1)
      end        
    end
  end
  
  bN.moveTo(1)
end

function populateEnchantments()
  print("do populateEnchantments:")
  
  foreachShelf(populateEnchantmentsCheck)
  
  table.sort(enchantments, function(a, b) return a:upper() < b:upper() end)
end

function populateEnchantmentsCheck(pos, level, side)
  local size = dC.inv.getInventorySize(side)
  print("side: " .. side .. "  size: " .. serialization.serialize(size))
  for i=1,size,1 do
    local item = dC.inv.getStackInSlot(side, i)
    if item and item.name ~= "minecraft:air" then
      print(serialization.serialize(item))
      -- TODO get enchantment and save in list
    end
  end
end

function checkOrder()
  print("do populateEnchantments:")
  
  foreachShelf(checkOrderSub)  
end

function checkOrderSub(pos, level, side)
  local size = dC.inv.getInventorySize(side)
  print("side: " .. side .. "  size: " .. serialization.serialize(size))
  for i=1,size,1 do
    local item = dC.inv.getStackInSlot(side, i)
    if item and item.name ~= "minecraft:air" then
      print(serialization.serialize(item))
      -- TODO get enchantment and check pos and level
    end
  end
end

function sortBook(ench, level)
  -- book in internalInv and selected
  local placed = false
      
  for i=1,#enchToMap,1 do
    if enchantments[i] == ench then
      local pos = enchToMap[i]
      local orientation = bN.map[pos].orientation
      local side = bN.map[pos].chest
    
      bN.moveTo(i)
      if level ~= 2 then
        bN.moveLevel(orientation, level, 1)
      end
      
      local size = dC.inv.getInventorySize(side)
      for j=1,size,1 do
        local item = dC.inv.getStackInSlot(side, j)
        if item == nil or item.name == "minecraft:air" then
          dC.inv.dropIntoSlot(side, j)
          placed = true
          break
        end
      end
      
      if level ~= 2 then
        bN.moveLevel(orientation, 2, 0)
      end
      break
    end
  end
  
  return placed
end

bN.closeGate()
populateEnchToMap()
populateEnchantments()

--while true do
--  print(sendCommand("getPos()"))
--  os.sleep(1)
--end