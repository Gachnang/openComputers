local gLt = {}
local man = {}

man.nextEmptySlot = "function(proxy:table, side:number[, start:number]):number -- Gets the next free slot in container"
function gLt.nextEmptySlot(proxy, side, start)
  local t = proxy.getAllStacks(side)
  
  local count = t.count()
  local i = start
  
  if i == nil or i > count then
    i = 1
  end
  
  for i=i,count,1 do
    if t[i].name == "minecraft:air" then
      return i
    end
  end
  return -1
end

function gLt.isEmpty(proxy, side) 
  local t = proxy.getAllStacks(side)
  local count = t.count()
  
  for i=1,count,1 do
    if t[i].name ~= "minecraft:air" then
      return false
    end
  end
  return true
end

function gLt.transferAll(proxy, sideSource, sideSink)
  local count = 0
  local sourcePos = 1
  local sourceTable = proxy.getAllStacks(sideSource)
  local sourceCount = sourceTable.count()
  local sinkPos = gLt.nextEmptySlot(proxy, sideSink)
  local sinkCount = proxy.getAllStacks(sideSink).count()
  
  if sinkPos == -1 then
    return count
  end
  
  for sourcePos=sourcePos,sourceCount,1 do
    if sourceTable[sourcePos].name ~= "minecraft:air" then
      proxy.transferItem(sideSource, sideSink, proxy.getSlotStackSize(sideSource, sourcePos), sourcePos, sinkPos)
      count = count + 1
      -- recalc sinkPos
      sinkPos = nextEmptySlot(proxy, sideSink, sinkPos)
      if sinkPos == -1 then
        --reached end
        sinkPos = nextEmptySlot(proxy, sideSink)
        if sinkPos == -1 then
          --Sink is full
          break
        end
      end
    end
  end
  return count
end

function gLt.findByLabel(proxy, side, label, pos)
  local t = proxy.getAllStacks(side)
  local count = t.count()
  
  if pos == nil then
    pos = 1
  end
  
  for pos=pos,count,1 do
    if t[pos].label == label then
      return pos
    end
  end
   
  return -1
end

function gLt.findByName(proxy, side, name, pos)
  local t = proxy.getAllStacks(side)
  local count = t.count()
  
  if pos == nil then
    pos = 1
  end
  
  for pos=pos,count,1 do
    if t[pos].name == name then
      return pos
    end
  end
   
  return -1
end

function gLt.countByName(proxy, side, name, pos)
  local t = proxy.getAllStacks(side)
  local count = t.count()
  local ret = 0
  
  if pos == nil then
    pos = 1
  end
  
  for pos=pos,count,1 do
    if t[pos].name == name then
      ret = ret + proxy.getSlotStackSize(side, pos)
    end
  end
   
  return ret
end

function gLt.countByLabel(proxy, side, label, pos)
  local t = proxy.getAllStacks(side)
  local count = t.count()
  local ret = 0
  
  if pos == nil then
    pos = 1
  end
  
  for pos=pos,count,1 do
    if t[pos].label == label then
      ret = ret + proxy.getSlotStackSize(side, pos)
    end
  end
   
  return ret
end

function gLt.findByDb(proxyDb, dbSlot, proxyTransposer, side)
  local t = proxyTransposer.getAllStacks(side)
  local count = t.count()
  
  for pos=1,count,1 do    
    if proxyTransposer.compareStackToDatabase(side, pos, proxyDb.address, dbSlot, true) then
      return pos
    end
  end
   
  return -1
end

--function tablelength(T)
--  local count = 0
--  for _ in pairs(T) do count = count + 1 end
--  return count
--end
  
return gLt, nil, man