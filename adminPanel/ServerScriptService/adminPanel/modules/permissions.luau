--================================================
-- Varaibles & Services
--================================================
-- Services
local Players = game:GetService("Players")
local GroupService = game:GetService("GroupService")
local Config = require(game.ReplicatedStorage.adminPanel:WaitForChild("config", 5))

-- Variables
local module = {}
module.players = {}

--================================================
-- Functions
--================================================
function module.fetchPlayerGroup(player: Players)
	local success, result = pcall(function()
		return GroupService:GetRolesInGroupAsync(player.UserId, Config.communityId)
	end)

	if not success or not result.IsMember then
		module.players[player.Name] = Config.defaultGroup
		return
	end

	local highestRole = 1
	local roleName = Config.defaultGroup
	for _, role in ipairs(result.Roles) do
		if role.Rank > highestRole and Config.groups[role.Name] then
			roleName = role.Name
			highestRole = role.Rank
		end
	end

	module.players[player.Name] = roleName
	return roleName
end

function module.getPlayerRole(rawPlayer)
	if rawPlayer and rawPlayer.Name then
		return module.players[rawPlayer.Name] or Config.defaultGroup
	end

	return module.players[rawPlayer] or Config.defaultGroup
end

function module.hasPlayerGroup(playerName, group)
	return module.getPlayerRole(playerName) == group or false
end

function module.hasPlayerPermissions(playerName, requireGroup)
	local playerRole = module.getPlayerRole(playerName)
	local requiredLevel = Config.groups[requireGroup] or 0
	local playerLevel = Config.groups[playerRole] or 0

	return playerLevel >= requiredLevel or false
end

--================================================
-- Init
--================================================
module.init = function(api)
	Players.PlayerAdded:Connect(function(player)
		local roleName = module.fetchPlayerGroup(player)
		task.wait(2)
		if roleName ~= Config.defaultGroup then
			api.sendClientMessage(player.Name, ("Welcome back `%s`, Group: `%s`"):format(player.Name, roleName))
		end

		api.fireClientEvent("updateUserGroup", player.Name, roleName)
	end)
	Players.PlayerRemoving:Connect(function(player)
		module.players[player.Name] = nil
	end)

	-- Auto Checker for rolls to update
	task.spawn(function()
		local oldPlayers = {}
		while true do
			task.wait(Config.updateGroupInterval or 60)

			for _, player in Players:GetPlayers() do
				oldPlayers[player.Name] = module.players[player.Name]
				local oldRole = oldPlayers[player.Name]
				local newRole = module.fetchPlayerGroup(player)

				if oldRole ~= newRole then
					api.sendClientMessage(player.Name, ("You role has been updated to `%s`"):format(newRole))
					api.fireClientEvent("updateUserGroup", player.Name, newRole)
				end
			end
		end
	end)

	api.registerSharedEvent("getUserGroup", function(userName)
		local userGroup = module.players[userName]
		if userGroup then
			return userGroup
		end

		userGroup = module.fetchPlayerGroup(userName)
		return userGroup
	end, true)

	api.registerClientEvent("updateUserGroup")
end

--================================================
-- API
--================================================
module.sharedFunctions = {
	getPlayerRole = module.getPlayerRole,
	hasPlayerGroup = module.hasPlayerGroup,
	hasPlayerPermissions = module.hasPlayerPermissions,
}

-- Return - End Module!
return module
