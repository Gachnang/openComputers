local GUI = require("GUI")
local text = require("Text")
local system = require("System")

--------------------------------------------------------------------------------
function writer(term, color)
    local w = {}
    
    w.write = function(writer, ...)
        local args = table.pack(...)
        for i=1,#args do
            local newLine = {
                color = color
            }
            
            if type(args[i]) == "string" then
                newLine.text = args[i]
            elseif type(args[i]) == "table"
                if type(args[i].text) == "string" then
                    newLine.text = args[i].text
                    if type(args[i].color) == "number" then
                        newLine.color = args[i].color
                    end
                else
                    error("wrong arguments for writer. Table without field \"text\"")
                end
            else
                error("wrong arguments for writer. Not a string or table, got " .. type(args[i]))
            end
            
            table.insert(term.textbox.lines)
        end
        
        if #term.textbox.lines > term.maxLines then
            for i=1,term.maxLines - #term.textbox.lines do
                table.remove(term.textbox.lines, 1)
            end
        end
    end
    
    return w
end
--------------------------------------------------------------------------------
function reader(term)
    local r = {}
    
    r.input = function(...)
        term.stdout:write(...)
        term.onInput = true
        
        while term.onInput == true do 
            os.sleep(0.1)
        end
        
        return term.onInput
    end
    
    return r
end
--------------------------------------------------------------------------------
function termExecuteResult(term, result, reason)
    local r = result
    local b = term.stdout
    if not result then 
        r = reason
        b = term.stderror
    end
    
    if type(r) == "string" then
        term.stdout:write(r)
    else
        term.stdout:write(text.serialize(r))
    end
end

function termInputOnInputFinished = function(term) 
    return function(application, input)
        if term.onInput == true then
            term.onInput = input.text
        else
            term:termExecuteResult(term.shell.execute(input.text, term.env))
        end
    end
end

function term(x, y, width, height)
    local userSettings = system.getUserSettings()
	local term = GUI.container(x, y, width, height)
    
    term.shell = require("shell")
    term.maxLines = userSettings.terminal.maxLines
    
    term.textbox = GUI.textbox(0, 0, width, height - 20, 0xFFFFFF, 0x000000, {}, 1, GUI.ALIGNMENT_HORIZONTAL_LEFT, GUI.ALIGNMENT_VERTICAL_BOTTOM, true, false)
    term:addChild(term.textbox)
    
    term.input = GUI.input(0, height - 20, width, 20, 0xFFFFFF, 0x000000, {})
    term.input.historyLimit = userSettings.terminal.historyLimit
    term.input.historyEnabled = true
    term.input.onInputFinished = termInputOnInputFinished(term)
    term.onInput = false
    term:addChild(term.input)
    
    term.stdout = writer(term, 0xFFFFFF)
    term.stderror = writer(term, 0xAA0000)
    term.stdinput = reader(term)
    term.env = {
        stdout = term.stdout,
        stderror = term.stderror,
        stdinput = term.stdinput,
        print = function(...)
            term.stdinput:write(...)
        end
    }
end