local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

local command = {}

command.description = "Clear a players inventory"
command.group = "Owner"
command.autoComplete = true

command.onExecute = function(api, player, args)
	local targetName = args[1]

	if not targetName then
		return api.sendClientMessage(player, "Gebruik /clearInventory <userName>", "error")
	end

	local success, userId = pcall(function()
		return Players:GetUserIdFromNameAsync(targetName)
	end)

	if not success then
		return api.sendClientMessage(player, ("Player `%s` does not exists!"):format(targetName), "error")
	end

	local inventoryStore = DataStoreService:GetDataStore("PlayerData", "Inventory")

	local success, errorMessage = pcall(function()
		inventoryStore:RemoveAsync(tostring(userId))
	end)

	if not success then
		warn("Inventory verwijderen mislukt:", errorMessage)
		return api.sendClientMessage(player, ("Inventory could not be cleared for player `%s`"):format(targetName), "error")
	end

	local targetPlayer = Players:GetPlayerByUserId(userId)

	if targetPlayer then
		local playerData = targetPlayer:FindFirstChild("PlayerData")

		if playerData then
			local inventory = playerData:FindFirstChild("Inventory")

			if inventory then
				inventory:ClearAllChildren()
			end
		end

		local backpack = targetPlayer:FindFirstChild("Backpack")

		if backpack then
			backpack:ClearAllChildren()
		end

		-- Eventuele equipped tools verwijderen
		if targetPlayer.Character then
			for _, object in ipairs(targetPlayer.Character:GetChildren()) do
				if object:IsA("Tool") then
					object:Destroy()
				end
			end
		end
	end

	api.sendClientMessage(player, ("Inventory is gecleared for player `%s`"):format(targetName), "info")
end

return command