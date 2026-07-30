local utils = {}


utils.Colors = {
	info = Color3.fromRGB(85, 170, 255),
	success = Color3.fromRGB(87, 242, 135),
	warning = Color3.fromRGB(255, 200, 0),
	warn = Color3.fromRGB(255, 200, 0),
	error = Color3.fromRGB(255, 85, 85),
}

function utils:getColorOfType(actionType: string?): Color3
	local action = (actionType or "info"):lower()
	return utils.Colors[action] or Color3.fromRGB(255, 255, 255)
end
function utils:escapeRichText(text: string): string
    if not text then
        return
    end

	text = text:gsub("&", "&amp;")
	text = text:gsub("<", "&lt;")
	text = text:gsub(">", "&gt;")
	text = text:gsub('"', "&quot;")
	return text
end

return utils