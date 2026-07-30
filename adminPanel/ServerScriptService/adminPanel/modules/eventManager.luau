--================================================
-- Variables & Services
--================================================
local Players = game:GetService("Players")

local module = {}
module.clientEvents = {}
module.sharedFunctions = {}


function module.getPlayer(rawPlayer)
	if rawPlayer and rawPlayer.Name then
		return Players:FindFirstChild(rawPlayer.Name)
	end

	local playerId = Players:GetUserIdFromNameAsync(rawPlayer)


	return Players:GetPlayerByUserId(playerId)
end

--================================================
-- Functions -- Clients
--================================================
function module.registerClientEvent(eventName)
	if type(eventName) == "table" then
		local events = {}
		for _, name in ipairs(eventName) do
			events[#events + 1] = module.registerClientEvent(name)
		end
		return events
	end

	assert(type(eventName) == "string", "eventName must be a string or an array of strings")

	if module.clientEvents[eventName] then
		error(("[adminPanel]: Event `%s` has already been loaded!!"):format(eventName))
		return true
	end

	local event = Instance.new("RemoteEvent")
	event.Name = eventName
	event.Parent = game.ReplicatedStorage.adminPanel

	module.clientEvents[eventName] = true
	return event
end

function module.fireClientEvent(eventName, playerName, ...)
	if not module.clientEvents[eventName] then
		return error(("[adminPanel]: Event `%s` has not been loaded/registered!"):format(eventName))
	end

	local player = module.getPlayer(playerName)

	game.ReplicatedStorage.adminPanel[eventName]:FireClient(player, ...)
end

function module.fireAllClientsEvent(eventName, ...)
	if not module.clientEvents[eventName] then
		return error(("[adminPanel]: Event `%s` has not been loaded/registered!"):format(eventName))
	end

	game.ReplicatedStorage.adminPanel[eventName]:FireAllClients(...)
end
--================================================
-- Functions -- sharedFunction
--================================================
function module.registerSharedEvent(eventName, func, isCallback)
	assert(type(eventName) == "string", "eventName is required!")
	assert(type(func) == "function", "function is required!")

	if module.sharedFunctions[eventName] then
		error(("[adminPanel]: Event `%s` has already been loaded!!"):format(eventName))
	end

	local object

	if isCallback then
		object = Instance.new("BindableFunction")
		object.OnInvoke = func
	else
		object = Instance.new("BindableEvent")
		object.Event:Connect(func)
	end

	object.Name = eventName
	object.Parent = game.ReplicatedStorage.adminPanel

	module.sharedFunctions[eventName] = object
end

--================================================
-- Functions -- general
--================================================
module.init = function()
	-- Pre Created Events!
	module.registerClientEvent("notify")
end


--================================================
-- API
--================================================
module.sharedFunctions = {
	registerClientEvent = module.registerClientEvent,
	fireClientEvent = module.fireClientEvent,
	fireAllClientsEvent = module.fireAllClientsEvent,
	registerSharedEvent = module.registerSharedEvent,

	-- Pre Created Events!
	sendClientMessage = function(playerName, message, messageType, messageLabel)
		module.fireClientEvent("notify", playerName, { message = message, label = (messageLabel or "adminPanel"), messageType = "success" })
	end,
}

return module