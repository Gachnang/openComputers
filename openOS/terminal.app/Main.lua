
-- Import libraries
local GUI = require("GUI")
local system = require("System")

local version = 1.0

--userSettings------------------------------------------------------------------
local userSettings = system.getUserSettings()

if type(userSettings.terminal) ~= "table" then
    userSettings.terminal = {}
end

if userSettings.terminal.version == nil or userSettings.terminal.version < version then
    local paths = {
        "/Applications/",
        "/Applications/Terminal.app/bin/"
    }
    
    if userSettings.terminal.paths == nil or type(userSettings.terminal.paths) ~= "table" then
        userSettings.terminal.paths = paths
    else 
        for i=1,#paths do
            local found = false
            for j=1,#userSettings.terminal.paths do
                if paths[i] == userSettings.terminal.paths[i] then
                    found = true
                    break
                end
            end
            if found == false then
                table.insert(userSettings.terminal.paths, paths[i])
            end
        end
    end
    
    userSettings.terminal.aliases = {}
    historyLimit = 10
    
    userSettings.terminal.version = version
    
    system.saveUserSettings()
end
--------------------------------------------------------------------------------

-- Add a new window to MineOS workspace
local workspace, window, menu = system.addWindow(GUI.filledWindow(1, 1, 60, 20, 0xE1E1E1))

-- Get localization table dependent of current system language
local localization = system.getCurrentScriptLocalization()

-- Add single cell layout to window
local layout = window:addChild(GUI.layout(1, 1, window.width, window.height, 1, 1))