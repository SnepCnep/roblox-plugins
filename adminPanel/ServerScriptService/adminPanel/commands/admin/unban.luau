local Players = game:GetService("Players")
local command = {}
local Config = {}

command.description = "unban a user of the game!"
command.group = "Admin"
command.autoComplete = true

--================================================
-- Functions
--================================================

--================================================
-- on command Registered
--================================================
command.init = function(api)
    Config = api.getConfig()
end

--================================================
-- on command Execute
--================================================
command.onExecute = function(api, player, args)
    local targetName = args[1]
    if not targetName then
        return api.sendClientMessage(player, "Gebruik /ban (username), (duration/1d), (banreden) ", "error")
    end

    local success, userId = pcall(function()
        return Players:GetUserIdFromNameAsync(targetName)
    end)

    if not success then
        return api.sendClientMessage(player, ("Player (%s) does not exists!"):format(targetName), "error")
    end

    local unbanSettings = {
		UserIds = { userId },
		ApplyToUniverse = false,
	}

	local success, err = pcall(function()
		return Players:UnbanAsync(unbanSettings)
	end)

    if not success then
        return api.sendClientMessage(player, ("Could not unban player: (%s)"):format(targetName), "error")
    end

    return api.sendClientMessage(player, ("Player: (%s) has success been unbanned!"):format(targetName), "success")
end

return command