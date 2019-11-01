local fs = require("fs")
local unicode = require("unicode")
local system = require("System")
local userSettings = system.getUserSettings()

local shell = {
    _p = {
        workingDirectory = "/",
        lastCommands = {}
    }
}

function shell.getAlias(alias)
  return shell.aliases()[alias]
end

function shell.setAlias(alias, value)
  checkArg(1, alias, "string")
  checkArg(2, value, "string", "nil")
  shell.aliases()[alias] = value
  system.saveUserSettings()
end

function shell.getWorkingDirectory()
  return shell._p.workingDirectory or "/"
end

function shell.setWorkingDirectory(dir)
  checkArg(1, dir, "string")
  -- ensure at least /
  -- and remove trailing /
  dir = fs.canonical(dir):gsub("^$", "/"):gsub("(.)/$", "%1")
  if fs.isDirectory(dir) then
    shell._p.workingDirectory = dir
    return true
  else
    return false, "not a directory"
  end
end

function shell.resolve(path, ext)
  checkArg(1, path, "string")

  local dir = path
  if dir:find("/") ~= 1 then
    dir = fs.concat(shell.getWorkingDirectory(), dir)
  end
  local name = fs.name(path)
  dir = fs[name and "path" or "canonical"](dir)
  local fullname = fs.concat(dir, name or "")

  if not ext then
    return fullname
  elseif name then
    checkArg(2, ext, "string")
    -- search for name in PATH if no dir was given
    -- no dir was given if path has no /
    local search_in = path:find("/") and dir or table.concat(shell.getPath(), ":")
    for search_path in string.gmatch(search_in, "[^:]+") do
      -- resolve search_path because they may be relative
      local search_name = fs.concat(shell.resolve(search_path), name)
      if not fs.exists(search_name) then
        search_name = search_name .. "." .. ext
      end
      -- extensions are provided when the caller is looking for a file
      if fs.exists(search_name) and not fs.isDirectory(search_name) then
        return search_name
      end
    end
  end

  return nil, "file not found"
end

function shell.parse(...)
  local params = table.pack(...)
  local args = {}
  local options = {}
  local doneWithOptions = false
  for i = 1, params.n do
    local param = params[i]
    if not doneWithOptions and type(param) == "string" then
      if param == "--" then
        doneWithOptions = true -- stop processing options at `--`
      elseif param:sub(1, 2) == "--" then
        local key, value = param:match("%-%-(.-)=(.*)")
        if not key then
          key, value = param:sub(3), true
        end
        options[key] = value
      elseif param:sub(1, 1) == "-" and param ~= "-" then
        for j = 2, unicode.len(param) do
          options[unicode.sub(param, j, j)] = true
        end
      else
        table.insert(args, param)
      end
    else
      table.insert(args, param)
    end
  end
  return args, options
end

function shell.aliases()
  return userSettings.terminal.aliases
end

function shell.execute(command, env)
    checkArg(path, "string")
    checkArg(env, "table", nil)

    table.insert(shell._p.lastCommands, command)
    if #shell._p.lastCommands > userSettings.terminal.countLastCommands then
        table.remove(shell._p.lastCommands, 1)
    end

    local path = ""
    if command:find("\"") == 1 then
        -- path to command is in quotes
        path = command:match([[".+"]])
    else
        -- path to command is first word
        local pathPos = command:find(" ")
        if pathPos and pathPos > 1 then
            path = command:sub(1, pathPos - 1)
        else
            path = command
        end
        path = command:match([[".+"]])
    end
    
    local args, options = shell.parse(command:sub(path:len()))

    local program, reason = shell.resolve(path, "lua")
    if program then
        return pcall(function(env, programm, options)
            if env ~= nil and type(env) == "table" then
                for key,value in pairs(env) do
                    _G[key] = value
                end
            end
            
            return programm(table.unpack(options))
        end, env, programm, options)
    end
    return nil, reason
end

function shell.getPath()
  return userSettings.terminal.paths
end

-------------------------------------------------------------------------------

return shell
