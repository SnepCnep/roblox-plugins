--================================================
-- Variables & Services
--================================================

-- Services
local Players = game:GetService("Players")
local GroupService = game:GetService("GroupService")
local TextChatService = game:GetService("TextChatService")

-- Varaibles
local api = {}

--================================================
-- Config Loader
--================================================
local Config = require(game.ReplicatedStorage.adminPanel:WaitForChild("config", 5))

function api.getConfig()
	return Config
end
--================================================
-- Module Loader
--================================================
local mdLoader = {}
mdLoader.modules = script:waitForChild("modules", 5)
mdLoader.loadOrder = {
	"eventManager",
	"permissions",
	"dataManager",
}

function mdLoader.loadModule(module)
	task.spawn(function()
		local success, result = pcall(require, module)
		if success then
			if result.init then
				pcall(result.init, api)
			end
			if result.sharedFunctions then
				for name, func in result.sharedFunctions do
					if api[name] then
						warn(("[adminPanel]: Function '" .. name .. "' already exists."))
					end

					api[name] = func
				end
			end
			print("[adminPanel]: Module '" .. module.Name .. "' loaded.")
		else
			warn("[adminPanel]: Error loading module:", module.Name, result)
		end
	end)
end

task.spawn(function()
	if not mdLoader or not mdLoader.modules then
		return warn("[adminPanel]: Folder `modules` not found!")
	end

	local allModules = mdLoader.modules:GetChildren()
	local loaded = {}

	for _, name in ipairs(mdLoader.loadOrder) do
		local module = mdLoader.modules:FindFirstChild(name)
		if module and module:IsA("ModuleScript") then
			mdLoader.loadModule(module)
			loaded[module] = true
		else
			warn(("[adminPanel]: Module '%s' from LOAD_ORDER not found!"):format(name))
		end
	end

	for _, module in allModules do
		if module:IsA("ModuleScript") and not loaded[module] then
			mdLoader.loadModule(module)
		end
	end
end)

--================================================
-- Command Loader
--================================================
local cmdLoader = {}

cmdLoader.commandlist = script:waitForChild("commands", 5)
cmdLoader.cmdPrefix = Config.cmdPrefix or "/"
cmdLoader.commands = {}

function cmdLoader.createCommand(name, result)
	local command = Instance.new("TextChatCommand")
	command.Name = name
	command.AutocompleteVisible = false
	command.PrimaryAlias = cmdLoader.cmdPrefix .. name
	if result.alias then
		command.SecondaryAlias = cmdLoader.cmdPrefix .. result.alias
	end
	command.Parent = TextChatService:WaitForChild("TextChatCommands", 5)
	command.Triggered:Connect(function(player: Player, text: string)
		local hasPermissions = api.hasPlayerPermissions(player, (result.group or Config.defaultGroup))

		if not hasPermissions then
			api.sendClientMessage(player.Name, "You dont have the right permissions for this command!", "error")
			return
		end
		local args = string.split(text, " ")
		table.remove(args, 1)
		local success, err = pcall(result.onExecute, api, player, args)
		if not success then
			warn("[adminPanel]: Error executing command:", name, err)
		end
	end)

	command:SetAttribute("autoComplete", (result.autoComplete or false))
	command:SetAttribute("group", (result.group or Config.defaultGroup))

	cmdLoader.commands[name] = { ["data"] = result, ["instance"] = command }
end

-- Help Command
cmdLoader.createCommand("adminhelp", {
	alias = "ahelp",
	autoComplete = true,
	onExecute = function(api, player, args)
		local cmdName = args[1]
		if not cmdName then
			return api.sendClientMessage(player.Name, "Give a `commandName` with /adminHelp `commandName`!", "error")
		end
		local command = cmdLoader.commands[cmdName]
		if not command or not command["data"] then
			return api.sendClientMessage(player.name, "This command does not exists!", "error")
		end
		local commandData = command["data"]

		local out = {
			("Command: %s"):format(cmdName),
		}
		if commandData.description then
			table.insert(out, ("Description: %s"):format(commandData.description))
		end
		if commandData.alias then
			table.insert(out, ("Alias: %s"):format(commandData.alias))
		end
		if commandData.group then
			table.insert(out, ("Group: %s"):format(commandData.group))
		end

		local message = "\n" .. table.concat(out, "\n")
		api.sendClientMessage(player.Name, message, "info")
	end
})


task.spawn(function()
	if not cmdLoader or not cmdLoader.commandlist then
		return warn("[adminPanel]: Folder `commands` not found!")
	end

	local function loadCommandsFrom(parent)
		for _, item in ipairs(parent:GetChildren()) do
			if item:IsA("ModuleScript") then
				task.spawn(function()
					local success, result = pcall(function()
						return require(item)
					end)
					if success then
						if result.init then
							pcall(result.init, api)
						end
						cmdLoader.createCommand(item.Name, result)
					else
						warn("[adminPanel]: Error loading command:", item.Name, result)
					end
				end)
			elseif item:IsA("Folder") then
				loadCommandsFrom(item)
			end
		end
	end

	loadCommandsFrom(cmdLoader.commandlist)
end)

