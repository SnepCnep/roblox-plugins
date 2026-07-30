-- Service
local textChatService = game:GetService("TextChatService")

-- Vairables
local Config = require(game.ReplicatedStorage.adminPanel:WaitForChild("config", 5))

-- Modules 
local modulePath = script:waitForChild("modules", 5)
local commandPath = script:waitForChild("commands", 5)
local regcmdPath = textChatService:FindFirstChild("TextChatCommands") or Instance.new("Folder")

local function loadModule(moduleName)
	local ok, module = pcall(require, modulePath[moduleName])
	if not ok then
		warn("Failed to load module:", moduleName, module)
		return nil
	end

	return module
end

local ev = loadModule("eventManager")
local notify = loadModule("notificationHandler")

--================================================
-- General functions
--================================================
local function hasPlayerPermissions(userGroup, requireGroup)
	local requiredLevel = Config.groups[requireGroup] or 0
	local playerLevel = Config.groups[userGroup] or 0

	return playerLevel >= requiredLevel or false
end

--================================================
-- Server Register
--================================================
ev.registerClientEvent("notify", function(data)
	notify.show(data)
end)


--================================================
-- Client Group Manager
--================================================
local function updateCommandsSuggestie(userGroup)
	local registeredCommands = regcmdPath:GetChildren()
	for _, command in pairs(registeredCommands) do
		local autoComplete = (command:GetAttribute("autoComplete") or false)
		if autoComplete then
			local cmdGroup = (command:GetAttribute("group") or "Member")
			local hasPermissions = hasPlayerPermissions(userGroup, cmdGroup)

			command.AutocompleteVisible = hasPermissions
		end
	end
end

ev.registerClientEvent("updateUserGroup", function(group)
	updateCommandsSuggestie(group)
end)
