serialization = require("serialization")
component = require("component")
sides = require("sides")
dC = require("droneController")

local bN = {
  gateOpen = true,
  gateSide = sides.right,
  dronePosMap = 1,
  map = require("biblioMap")
}

local gate = component.redstone

-- find the path between two points on the map
function bN.findPath(from, to)
  local fromList = bN.findPathHome(from)
  local toList = bN.findPathHome(to)
  
  for f=1,#fromList,1 do
    for t=1,#toList,1 do
      if fromList[f] == toList[t] then
        local ret={}
        for f2=1,f,1 do ret[#ret+1] = fromList[f2] end
        for t2=t-1,1,-1 do ret[#ret+1] = toList[t2] end
        
        print("Path from " .. from .. " to " .. to .. ":")
        print(serialization.serialize(ret))
        
        return ret
      end
    end
  end
end

-- find the path home from the map and return it as table
function bN.findPathHome(from)
  local list = {}
  list[#list+1] = from
  
  while list[#list] > 1 and list[#list] <= #bN.map and bN.map[list[#list]] ~= nil and bN.map[list[#list]].back ~= nil do
    list[#list+1] = bN.map[list[#list]].back
  end
  
  return list
end

-- open the gate to let drone in/out
function bN.openGate()
  if not bN.gateOpen then
    print("openGate")
    if gate then
      gate.setOutput(bN.gateSide, 0)
    end
    bN.gateOpen = true
  end
end

-- close tha gate
function bN.closeGate()
  if bN.gateOpen then
    print("closeGate")
    if gate then
      gate.setOutput(bN.gateSide, 15)
    end
    bN.gateOpen = false
  end
end

-- move drone to pos on map
function bN.moveTo(to, wait)
  local list = bN.findPath(bN.dronePosMap, to)
  
  if wait == nil then
    wait = 0
  end
    
  for i=1,#list,1 do
    local nextPos = bN.map[list[i]].pos
    local waitLoop = 0
    
    if bN.gateOpen == false and list[i] <= 2 and #list > i and list[i+1] <= 2 then
      bN.openGate()
      waitLoop = 1
    elseif i == #list then
      waitLoop = wait
    end
    
    dC.drone.move(
      nextPos.dx - dC.dronePos.dx,
      nextPos.dy - dC.dronePos.dy,
      nextPos.dz - dC.dronePos.dz,
      waitLoop)
    
    bN.dronePosMap = to
      
    if bN.gateOpen and ((list[i] > 2) or (#list == i and list[i] == 1)) then
      bN.closeGate()
    end
  end
end

-- move drone on the heigth between level 1 to 3
function bN.moveLevel(orientation, level, wait)
  local currentLevel = 0
  
  if level < 1 then
    level = 1
  elseif level > 3 then
    level = 3
  end
  
  if wait == nil then 
    wait = 1 
  end
  
  print("moveLevel orientation: " .. orientation .. "  level: " .. level)
  print(serialization.serialize(dC.dronePos))
  
  if orientation == "x" then 
    currentLevel = ((-1) * bN.map[bN.dronePosMap].pos.dx - dC.dronePos.dx) + 2
    print("  Current Level: " .. currentLevel)
    print("  x: " .. ((-1) * (currentLevel - level)))
    return dC.drone.move((-1) * (currentLevel - level),0,0,wait)
  elseif orientation == "-x" then
    currentLevel = bN.map[bN.dronePosMap].pos.dx - dC.dronePos.dx + 2
    print("  Current Level: " .. currentLevel)
    print("  x: " .. (currentLevel - level))
    return dC.drone.move(currentLevel - level,0,0,wait)
  elseif orientation == "z" then
    currentLevel = bN.map[bN.dronePosMap].pos.dz - dC.dronePos.dz + 2
    print("  Current Level: " .. currentLevel)
    print("  z: " .. (currentLevel - level))
    return dC.drone.move(0,0,(currentLevel - level),wait)
  elseif orientation == "-z" then
    currentLevel = bN.map[bN.dronePosMap].pos.dz - dC.dronePos.dz - 2
    print("  Current Level: " .. currentLevel)
    print("  z: " .. ((-1) * (currentLevel - level)))
    return dC.drone.move(0,0,(-1) * (currentLevel - level),wait)
  end
end

return bN