
local event = require("Event")
local filesystem = require("Filesystem")
local serialization = require("serialization")

local network = {}

----------------------------------------------------------------------------------------------------------------

local filesystemProxy = filesystem.proxy()

network.filesystemHandles = {}
network.modemPort = 1488
network.protocol = "network"

----------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------

function network.broadcastComputerState(state)
	return network.broadcastMessage(network.protocol, state and "computerAvailable" or "computerNotAvailable", network.nm.getModemProxyName(nm.modemProxy))
end

local exceptionMethods = {
	getLabel = function()
		return network.nm.modemProxy.address
	end,

	list = function(path)
		return serialization.serialize(filesystemProxy.list(path))
	end,

	open = function(path, mode)
		local ID
		while not ID do
			ID = math.random(1, 0x7FFFFFFF)
			for handleID in pairs(network.filesystemHandles) do
				if handleID == ID then
					ID = nil
                    break
				end
			end
		end

		network.filesystemHandles[ID] = filesystemProxy.open(path, mode)
		
		return ID
	end,

	close = function(ID)
		local data, reason = filesystemProxy.close(network.filesystemHandles[ID])
		network.filesystemHandles[ID] = nil
		return data, reason
	end,

	read = function(ID, ...)
		return filesystemProxy.read(network.filesystemHandles[ID], ...)
	end,

	write = function(ID, ...)
		return filesystemProxy.write(network.filesystemHandles[ID], ...)
	end,

	seek = function(ID, ...)
		return filesystemProxy.seek(network.filesystemHandles[ID], ...)
	end,
}

local function handleRequest(eventData)	
	local result = { pcall(exceptionMethods[eventData[8]] or filesystemProxy[eventData[8]], table.unpack(eventData, 9)) }
	network.sendMessage(eventData[3], "network", "response", eventData[8], table.unpack(result, result[1] and 2 or 1))
end

----------------------------------------------------------------------------------------------------------------

function network.onModemMessage(eventName, receiverAddress, senderAddress, port, distance, protocol, ...)
    local eventData = {eventName, receiverAddress, senderAddress, port, distance, protocol, ...}
    if eventData[7] == "request" then
        handleRequest(eventData)
	end
end

function network.destroy()
	network.networkEnabled = false
	network.broadcastComputerState(false)
    network.nm.modemProxy.close(network.modemPort)
    network.nm = nil
end

function network.init(nm)
	network.networkEnabled = true
    network.nm = nm
    network.nm.modemProxy.open(network.modemPort)
	network.broadcastComputerState(true)
end

return network, network.protocol




