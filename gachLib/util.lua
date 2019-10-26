local util = {}
local doc = {}

doc.deepcopy = "function(orig:any) -- copy a table, number, string, boolean, etc"
function util.deepcopy(orig, copies)
    copies = copies or {}
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            copies[orig] = copy
            setmetatable(copy, deepcopy(getmetatable(orig), copies))
            for orig_key, orig_value in next, orig, nil do
                copy[deepcopy(orig_key, copies)] = deepcopy(orig_value, copies)
            end
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function util.tableCount(t)
  local i = 0
  for _,_ in pairs(t) do
    i = i + 1
  end
  return i
end

function util.tableKeys(t)
  local keys = {}
  for key,_ in pairs(t) do
    keys[#keys + 1] = key
  end
  
  return keys
end

function util.tableValues(t)
  local values = {}
  for _,value in pairs(table) do
    values[#values + 1] = value
  end
  
  return values
end

return util, doc