local networkManager = {
    protocols = {}
}

function networkManager.addProtocol(protocol, name)
    checkArg(1, protocol, "table", "nil")
    checkArg(2, name, "string")

    if networkManager.protocols[name] ~= nil then
        networkManager.protocols[name].destroy()
    end
    
    networkManager.protocols[name] = protocol
    
    if networkManager.protocols[name] ~= nil and networkManager.enabled and type(networkManager.protocols[name].init) == "function" then 
        networkManager.protocols[name].init(networkManager)
    end
    
    return networkManager
end

function networkManager.removeProtocol(name)
    return networkManager.addProtocol(nil, name)
end

function network.sendMessage(port, address, protocol, ...)
    checkArg(1, port, "number")
    checkArg(2, address, "string")
    
	if networkManager.modemProxy then
		return networkManager.modemProxy.send(address, port, protocol, ...)
	else
		networkManager.modemProxy = nil
		return false, "Modem component is not available"
	end
end

function networkManager.broadcastMessage(port, protocol, ...)
	if networkManager.modemProxy then
		return networkManager.modemProxy.broadcast(port, protocol, ...)
	else
		networkManager.modemProxy = nil
		return false, "Modem component is not available"
	end
end

function networkManager.setSignalStrength(strength)
	if networkManager.modemProxy then
		if networkManager.modemProxy.isWireless() then
			return networkManager.modemProxy.setStrength(strength)
		else
			return false, "Modem component is not wireless"
		end
	else
		networkManager.modemProxy = nil
		return false, "Modem component is not available"
	end
end

function networkManager.getModemProxyName(proxy)
	return networkManager.computerName and networkManager.computerName .. " (" .. proxy.address .. ")" or proxy.address
end

function networkManager.onModemMessage(eventName, receiverAddress, senderAddress, port, distance, protocol, ...)
    if eventName == "modem_message" and networkManager.protocols[protocol] ~= nil and type(networkManager.protocols[protocol].onModemMessage) then
        networkManager.protocols[protocol].onModemMessage(eventName, receiverAddress, senderAddress, port, distance, protocol, ...)
    end
end

function networkManager.onUpdateComponents(...)
	local modem, internet = component.get("modem"), component.get("internet")
	if modem then
		networkManager.modemProxy = modem
	else
		networkManager.modemProxy = nil
	end
    
    for pName, p in networkManager.protocols do
        if p ~= nil and type(p.onUpdateComponents) == "function" then
            p.onUpdateComponents(...)
        end
    end
    
    return networkManager
end

function networkManager.init(computerName)
    networkManager.enabled = true
    networkManager.computerName = computerName
    modem.setWakeMessage("WakeUp_" .. networkManager.computername)
    
    networkManager.modemEventListener = event.listen("modem_message", networkManager.onModemMessage)
    networkManager.componentAddedEventListener = event.listen("component_added", networkManager.onUpdateComponents)
    networkManager.componentRemovedEventListener = event.listen("component_removed", networkManager.onUpdateComponents)
    
    for pName, p in networkManager.protocols do
        if p ~= nil and type(p.init) == "function" then
            p.init(networkManager)
        end
    end
end

function networkManager.destroy()
    networkManager.enabled = false
    
    if networkManager.modemEventListener ~= nil and type(networkManager.modemEventListener) == "number" then
      event.cancel(networkManager.modemEventListener)
    end
    
    if networkManager.componentAddedEventListener ~= nil and type(networkManager.componentAddedEventListener) == "number" then
      event.cancel(networkManager.componentAddedEventListener)
    end
    
    if networkManager.componentRemovedEventListener ~= nil and type(networkManager.componentRemovedEventListener) == "number" then 
      event.cancel(networkManager.componentRemovedEventListener)
    end
    
    for pName, p in networkManager.protocols do
        if p ~= nil and type(p.destroy) == "function" then
            p.destroy()
        end
    end 
end

function networkManager.addProtocolState()
    networkManager.addProtocol(require("gachLib.network.state"))
end

function networkManager.addProtocolFTP()
    networkManager.addProtocol(require("gachLib.network.ftpServerMineOs"))
end

return networkManager