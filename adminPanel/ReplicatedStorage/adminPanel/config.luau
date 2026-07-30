local Config = {}


-- Misc Config
Config.publicBanReason = "You have been banned on playing our game!"
Config.excludeAltBans = false -- True = Ignore alts accounts | False = Ban als account

-- Community Config
Config.communityId = 328981451

-- Permissions Config
Config.updateGroupInterval = 15
Config.defaultGroup = "Member"
Config.groups = {
	["Owner"]       = 500,
	["Developer"]   = 400,
	["Admin"]       = 300,
	["Moderator"]   = 200,
	["Member"]      = 0,
}






return Config