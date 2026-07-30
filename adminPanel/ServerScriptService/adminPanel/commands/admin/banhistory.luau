local Players = game:GetService("Players")
local command = {}
local Config = {}

command.description = "ban a user!"
command.group = "Admin"
command.autoComplete = true

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

    local success, result = pcall(function()
        return Players:GetBanHistoryAsync(userId)
    end)
    if not success then
        return api.sendClientMessage(player, ("Could not get the ban history of (%s)!"):format(targetName), "error")
    end

    print(result)

    return api.sendClientMessage(player, ("Player: (%s) has success been banned!"):format(targetName), "success")
end

return command