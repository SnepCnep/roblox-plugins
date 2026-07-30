local eventManager = {}

eventManager.clientEvents = {}

function eventManager.registerClientEvent(eventName, func)
	local event = game.ReplicatedStorage.adminPanel:WaitForChild(eventName, 10)

	if not event and not eventManager.clientEvents[eventName] then
		error(("[adminPanel]: Event `%s` has not been loaded/registered by the server!"):format(eventName))
		return
	end

	event = event or eventManager.clientEvents[eventName]
	event.OnClientEvent:Connect(function(...)
		pcall(func, ...)
	end)
end

return eventManager
