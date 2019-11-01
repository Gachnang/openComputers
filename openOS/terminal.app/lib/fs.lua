local fs = require("filesystem")

local function segments(path)
  local parts = {}
  for part in path:gmatch("[^\\/]+") do
    local current, up = part:find("^%.?%.$")
    if current then
      if up == 2 then
        table.remove(parts)
      end
    else
      table.insert(parts, part)
    end
  end
  return parts
end

function fs.canonical(path)
  local result = table.concat(segments(path), "/")
  if unicode.sub(path, 1, 1) == "/" then
    return "/" .. result
  else
    return result
  end
end

function fs.concat(...)
  local set = table.pack(...)
  for index, value in ipairs(set) do
    checkArg(index, value, "string")
  end
  return fs.canonical(table.concat(set, "/"))
end

return fs