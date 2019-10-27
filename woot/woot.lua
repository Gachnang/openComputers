-- import
sides = require("sides")
component = require("component")
g = require("gachLib")

--config
--oc
breakPlaceChestAddr = "c95e"

transposerDrawerAddr = "294d"
transposerDrawerSide = sides.east

redstoneBreakerAddr = "bc43"
redstoneBreakerSide = sides.west
transposerBreakerSide = sides.down

redstonePlacerAddr = "c01a"
redstonePlacerSide = sides.west
transposerPlacerSide = sides.up

transposerChestSide = sides.west

--woot
timePerFactory = 60
factoryTable = require("wootTable")

--vars
transposerBPC = component.proxy(component.get(breakPlaceChestAddr))
transposerDrawer = component.proxy(component.get(transposerDrawerAddr))
redstonePlacer = component.proxy(component.get(redstonePlacerAddr))
redstoneBreaker = component.proxy(component.get(redstoneBreakerAddr))

--func
function init()
  if g.network ~= nil then
    g.network.init("woot")
  end
  g.state.setState({state = "init", currentFactory = "<none>"})
end

function breakFactory(time)
  if time == nil then
    time = 10
  end

  redstoneBreaker.setOutput(redstoneBreakerSide, 0)
  os.sleep(0.5)

  while g.transposer.isEmpty(transposerBPC,transposerBreakerSide) and time > 0 do
    time = time - 1
    os.sleep(0.5)
  end

  redstoneBreaker.setOutput(redstoneBreakerSide, 15)
  g.transposer.transferAll(transposerBPC, transposerBreakerSide, transposerChestSide)  
end

function placeFactory(dbSlot, time)
  if time == nil then
    time = 10
  end
  
  local pos = g.transposer.findByDb(component.database, dbSlot, transposerBPC, transposerChestSide)
  if pos <= -1 then
    return false
  end
  
  transposerBPC.transferItem(transposerChestSide, transposerPlacerSide, transposerBPC.getSlotStackSize(transposerChestSide, pos), pos, 1)

  redstonePlacer.setOutput(redstonePlacerSide, 0)
  os.sleep(0.5)

  while not g.transposer.isEmpty(transposerBPC,transposerPlacerSide) and time > 0 do
    time = time - 1
    os.sleep(0.5)
  end

  redstonePlacer.setOutput(redstonePlacerSide, 15)
  
  return true
end

function updateFactoryTable()
  g.state.setState({state = "updateFactoryTable"})
  local ret = {name = nil, missingSum = 0, missingAVG = 0}
  local posF = 1
  print("updateFactoryTable")
  while factoryTable[posF] ~= nil do
    print("  " .. factoryTable[posF].name)
    local missingSum = 0
    local posI = 1
    
    while factoryTable[posF].items[posI] ~= nil do
      factoryTable[posF].items[posI].currentCount = 0
      if factoryTable[posF].items[posI].name ~= nil then
        factoryTable[posF].items[posI].currentCount = g.transposer.countByName(transposerDrawer, transposerDrawerSide, factoryTable[posF].items[posI].name)
      else
        factoryTable[posF].items[posI].currentCount = g.transposer.countByLabel(transposerDrawer, transposerDrawerSide, factoryTable[posF].items[posI].label)
      end
      
      factoryTable[posF].items[posI].differentCount = factoryTable[posF].items[posI].targetCount - factoryTable[posF].items[posI].currentCount
      
      if factoryTable[posF].items[posI].name ~= nil then
        print("    " .. factoryTable[posF].items[posI].name .. ": " .. factoryTable[posF].items[posI].currentCount .. " / " .. factoryTable[posF].items[posI].targetCount)
      else
        print("    " .. factoryTable[posF].items[posI].label .. ": " .. factoryTable[posF].items[posI].currentCount .. " / " .. factoryTable[posF].items[posI].targetCount)
      end
      
      if factoryTable[posF].items[posI].differentCount > 0 then
        missingSum = missingSum + factoryTable[posF].items[posI].differentCount
      end
      
      posI = posI + 1
    end
    local missingAVG = missingSum / (posI - 1)
    
    factoryTable[posF].missingSum = missingSum
    print("   Missing " .. missingSum .. "  (AVG: " .. missingAVG .. ")")
    
    if ret.name == nil or (missingSum > ret.missingSum and missingAVG > ret.missingAVG) then
      ret.name = factoryTable[posF].name
      ret.dbPos = factoryTable[posF].dbPos
      ret.missingSum = missingSum
      ret.missingAVG = missingAVG
    end
    
    posF = posF + 1
  end
  
  return ret
end

function nextFactory()
  local nextF = updateFactoryTable()
  
  if currentFactory == nil or currentFactory.name ~= nextF.name then
    breakFactory()
  
    if nextF.name == nil or nextF.missingSum <= 0 then
      print("No new factory aviable..")
      g.state.setState({state = "standby", currentFactory = "<none>"})
      return false
    end
  
    if placeFactory(nextF.dbPos) then
      currentFactory = nextF
      print("Placed next factory: " .. nextF.name)
      g.state.setState({state = "running", currentFactory = nextF.name})
    else
      print("!!! Failed to place next factory: " .. nextF.name)
      g.state.setState({state = "ERROR", currentFactory = "<none>"})
      return false
    end
  elseif nextF.missingSum > 0 then
    print("Stay on current factory: " .. nextF.name)
    g.state.setState({state = "running", currentFactory = nextF.name})
  else
    breakFactory()
    print("Go in StandBy.. ")
    g.state.setState({state = "standby", currentFactory = "<none>"})
  end
  return true
end

--Main
print("Start woot")
init()
breakFactory()
local currentTimePerFactory = 0
while true do
  if currentTimePerFactory <= 0 then
    if not nextFactory() then
      print("!")
    end
    currentTimePerFactory = timePerFactory
  end
  os.sleep(1)
  currentTimePerFactory = currentTimePerFactory - 1
  --print("Tick: " .. currentTimePerFactory)
end