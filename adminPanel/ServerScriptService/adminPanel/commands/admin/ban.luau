local Players = game:GetService("Players")
local command = {}
local Config = {}

command.description = "ban a user of the game!"
command.group = "Admin"
command.autoComplete = true

--================================================
-- Functions
--================================================
local banTimes = {
    ["permanent"] = 3122064000, -- 99 Years in seconds (99 * 31536000)
    ["perm"] = 3122064000, -- 99 Years in seconds (99 * 31536000)
    ["y"] = 31536000,
    ["mo"] = 2592000,
    ["d"] = 86400,
    ["h"] = 3600,
    ["m"] = 60,
    ["s"] = 1,
}
local function getTempDuration(durationInput)
    if not durationInput or typeof(durationInput) ~= "string" then
        return nil
    end

    local normalized = durationInput:lower():gsub("%s+", "")
    if normalized == "permanent" or normalized == "perm" then
        return banTimes.permanent
    end

    local totalSeconds = 0
    local foundUnit = false

    for amount, unit in normalized:gmatch("(%d+)([a-z]+)") do
        local multiplier = banTimes[unit]
        if not multiplier then
            return nil
        end

        totalSeconds = totalSeconds + tonumber(amount) * multiplier
        foundUnit = true
    end

    if not foundUnit or totalSeconds <= 0 then
        return nil
    end

    return totalSeconds
end
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

    local banReason = (#args >= 3) and table.concat({unpack(args, 3)}, " ") or nil
    local duration = getTempDuration(args[2])
    if not duration then
        return api.sendClientMessage(player, ("Invalid ban duration to ban: (%s)"):format(targetName), "error")
    end

    local banSettings = {
        UserIds = { userId },
        Duration = duration,
        DisplayReason = (Config.publicBanReason or "You have been banned!"),
        PrivateReason = (banReason or "No ban reason given!"),
        ExcludeAltAccounts = (Config.excludeAltBans or false ),
        ApplyToUniverse = true,
    }
    local success, err = pcall(function()
        return Players:BanAsync(banSettings)
    end)

    if not success then
        return api.sendClientMessage(player, ("Could not ban player: (%s)"):format(targetName), "error")
    end

    return api.sendClientMessage(player, ("Player: (%s) has success been banned!"):format(targetName), "success")
end

return command