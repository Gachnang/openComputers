component = require("component")
computer = require("computer")
serialization = require("serialization")
sides = require("sides")
g = require("gachLib")

local rec = require("draconicRec")

-- tells refinedStorage to start new crafting
redSideNewCrafting = sides.right
-- tells draconic infusion to start crafting (after all chests are empty)
redSideStartInjection = sides.back
-- tells enderIo to extract the result
redSideExtractResult = sides.left

-- side of transposer in which the items for crafting land
transSideInput = sides.north
-- side of transposer from which the items for the Core gets
transSideCore = sides.west
-- side of transposer from which the items for the Inject gets
transSideInject = sides.east
-- side of transposer in which the result of core land
transSideResult = sides.south

-- checks if chest on side is empty
function chestIsEmpty(side)
  local stacks = component.transposer.getAllStacks(side)
  for i=1,stacks.count(),1 do
    if stacks[i].name ~= "minecraft:air" then
      return false
    end
  end
  return true
end

function getItemsInInput()
  local stacks = component.transposer.getAllStacks(transSideInput)
  local ret = {}
  for i=1,stacks.count(),1 do
    if stacks[i].name ~= "minecraft:air" then
      for j=1,(#ret+1),1 do
        if j > #ret then
          ret[i] = {name = stacks[i].name, count = stacks[i].size, slot = j}
          break
        elseif ret[i] ~= nil and ret[i].name == stacks[i].name then
            ret[i].count = ret[i].count + stacks[i].size
            break
          end
        end
    end
  end
  return ret
end

-- tell refinedStorage to start next crafting and wait for new input   O(N^3)
function startNewCrafting()
  print("startNewCrafting")
  g.state.setState({state = "ready", recepie = "<none>"})
  while chestIsEmpty(transSideInput) do
    component.redstone.setOutput(redSideNewCrafting, 15)
    os.sleep(.1)
    component.redstone.setOutput(redSideNewCrafting, 0)
    os.sleep(1)
  end
end

function getRecepie()
  local ret = {recIndex = -1, coreSlot = -1, items = getItemsInInput()}
  
  for i=1,#rec,1 do
    local coreSlot = -1
    -- check item for core
    print(" check for core " .. i)
    for k=1,#ret.items,1 do
      if rec[i].core.name == ret.items[k].name and rec[i].core.count >= ret.items[k].count then
        print("  item for core found: " .. ret.items[k].name .. " in slot " .. ret.items[k].slot)
        coreSlot = ret.items[k].slot
        break
      end
    end
    
    -- check items for inject
    if coreSlot > 0 then
      local checked = 0
      for j=1,#rec[i].inject do
        print(" check for inject " .. j .. "/" .. #rec[i].inject)
        for k=1,#ret.items,1 do
          if rec[i].inject[j].name == ret.items[k].name and rec[i].inject[j].count >= ret.items[k].count then
            print("  item for inject found: " .. ret.items[k].name .. " in slot " .. ret.items[k].slot)
            checked = checked + 1
            break
          end
        end
      end
      if checked >= #rec[i].inject then
        ret.recIndex = i
        ret.coreSlot = coreSlot
        break
      end
    end
  end
  return ret
end

-- move input to the rigth chests
function moveInput()
  local retry = true
  
  while retry do
    print("moveInput")
    local recepie = getRecepie()
    print(serialization.serialize(recepie))
    if recepie.recIndex > 0 then
      g.state.setState({state = "crafting", recepie = rec[recepie.recIndex].name})
      moveToCore(recepie.coreSlot, recepie.recIndex)
      moveToInjection(recepie.recIndex)
      retry = false
    else
      print("No recepie found.. Retry")
      os.sleep(1)
    end
  end
end

-- move item from input in slot to core
function moveToCore(slot, recIndex)
  print("move to core " .. slot)
  component.transposer.transferItem(transSideInput, transSideCore, rec[recIndex].core.count, slot)
end

-- move all items from input to injection
function moveToInjection(recIndex)
  for i=1,component.transposer.getInventorySize(transSideInput),1 do
    local stack = component.transposer.getStackInSlot(transSideInput,i)
    if stack ~= nil and stack.name ~= "minecraft:air" then
      for j=1,#rec[recIndex].inject do
        if stack.name == rec[recIndex].inject[j].name then
          component.transposer.transferItem(
            transSideInput, 
            transSideInject, 
            rec[recIndex].inject[j].count,
            i,
            g.transposer.nextEmptySlot(component.transposer, transSideInject))
        end
      end
    end
  end
end

-- starts the injection
function startInjection()
  print("startInjection")
  while not chestIsEmpty(transSideInject) do
    os.sleep(1)
  end
  
  component.redstone.setOutput(redSideStartInjection, 15)
  os.sleep(1)
  component.redstone.setOutput(redSideStartInjection, 0)
end

-- wait for injection to finish
function awaitResult()
  print("awaitResult")
  while chestIsEmpty(transSideResult) do
    os.sleep(1)
  end
end

-- return result of injection
function returnResult()
  print("returnResult")
  component.redstone.setOutput(redSideExtractResult, 15)
  os.sleep(1)
  component.redstone.setOutput(redSideExtractResult, 0)
end

-- main
if g.network ~= nil then
    g.network.init("woot")
end
g.state.setState({state = "init"})

while true do
  startNewCrafting()
  moveInput()
  startInjection()
  awaitResult()
  returnResult()
end