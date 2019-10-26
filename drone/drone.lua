drone = component.proxy(component.list("drone")())
modem = component.proxy(component.list("modem")())
inv = component.proxy(component.list("inv")())
comport = 22
pos = {dx=0,dy=0,dz=0}

modem.open(comport)

function run()
  while true do
    local signalName, recieverAddr, senderAddr, port, range, payload, param = computer.pullSignal()
  
    if signalName == "modem_message" and senderAddr ~= modem.address then
      local success, message = pcall(load("result=" .. payload))
    
      if success then
        message = result
        if type(message) == "function" then message = "function" end
      end
    
      local ret = {
        success = success,
        message = message
      }
    
      modem.broadcast(comport, serialize(ret))
    end
  end
end

function move(dx, dy, dz, wait)
  pos.dx = pos.dx + dx
  pos.dy = pos.dy + dy
  pos.dz = pos.dz + dz
  
  drone.move(dx, dy, dz)
  
  if wait >= 1 or wait == nil then
    -- wait until target position reached
    while drone.getVelocity() > 0.5 or drone.getOffset() > 0.5 do
      sleep(0.1)
    end
  end
  
  return pos
end

function getPos()
  return pos
end

-- from os.sleep
function sleep(timeout)
  local deadline = computer.uptime() + (timeout or 0)
  -- busy-wait
  while computer.uptime() >= deadline do end
end

-- from serialization.lua
function serialize(value, pretty)
  local kw =  {["and"]=true, ["break"]=true, ["do"]=true, ["else"]=true,
               ["elseif"]=true, ["end"]=true, ["false"]=true, ["for"]=true,
               ["function"]=true, ["goto"]=true, ["if"]=true, ["in"]=true,
               ["local"]=true, ["nil"]=true, ["not"]=true, ["or"]=true,
               ["repeat"]=true, ["return"]=true, ["then"]=true, ["true"]=true,
               ["until"]=true, ["while"]=true}
  local id = "^[%a_][%w_]*$"
  local ts = {}
  local function s(v, l)
    local t = type(v)
    if t == "nil" then
      return "nil"
    elseif t == "boolean" then
      return v and "true" or "false"
    elseif t == "number" then
      if v ~= v then
        return "0/0"
      elseif v == math.huge then
        return "math.huge"
      elseif v == -math.huge then
        return "-math.huge"
      else
        return tostring(v)
      end
    elseif t == "string" then
      return string.format("%q", v):gsub("\\\n","\\n")
    elseif t == "table" then
      if ts[v] then
        error("recursion")
      end
      ts[v] = true
      local i, r = 1, nil
      local f
      if pretty then
        local ks, sks, oks = {}, {}, {}
        for k in pairs(v) do
          if type(k) == "number" then
            table.insert(ks, k)
          elseif type(k) == "string" then
            table.insert(sks, k)
          else
            table.insert(oks, k)
          end
        end
        table.sort(ks)
        table.sort(sks)
        for _, k in ipairs(sks) do
          table.insert(ks, k)
        end
        for _, k in ipairs(oks) do
          table.insert(ks, k)
        end
        local n = 0
        f = table.pack(function()
          n = n + 1
          local k = ks[n]
          if k ~= nil then
            return k, v[k]
          else
            return nil
          end
        end)
      else
        f = table.pack(pairs(v))
      end
      for k, v in table.unpack(f) do
        if r then
          r = r .. "," .. (pretty and ("\n" .. string.rep(" ", l)) or "")
        else
          r = "{"
        end
        local tk = type(k)
        if tk == "number" and k == i then
          i = i + 1
          r = r .. s(v, l + 1)
        else
          if tk == "string" and not kw[k] and string.match(k, id) then
            r = r .. k
          else
            r = r .. "[" .. s(k, l + 1) .. "]"
          end
          r = r .. "=" .. s(v, l + 1)
        end
      end
      ts[v] = nil -- allow writing same table more than once
      return (r or "{") .. "}"
    else
        error("unsupported type: " .. t)
    end
  end
  local result = s(value, 1)
  local limit = type(pretty) == "number" and pretty or 10
  return result
end

run()