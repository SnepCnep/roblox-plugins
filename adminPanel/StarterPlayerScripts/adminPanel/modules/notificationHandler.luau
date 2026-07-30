local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

-- adjust this path to wherever your utils module lives
local utils = require(script.Parent:WaitForChild("utils"))

local localPlayer = Players.LocalPlayer

local Notify = {}

-- config (tweak freely)
Notify.Duration = 5
Notify.MaxOnScreen = 5
Notify.LabelColor = "rgb(59,204,170)"
Notify.TitleColor = Color3.fromRGB(240, 240, 245)
Notify.BodyColor  = Color3.fromRGB(150, 153, 161)
Notify.CardColor  = Color3.fromRGB(26, 26, 31)

-- Build (or fetch) the container that holds the stack.
local function getHolder()
	local playerGui = localPlayer:WaitForChild("PlayerGui")
	local gui = playerGui:FindFirstChild("AdminNotifications")
	if gui then
		return gui:FindFirstChild("Holder")
	end

	gui = Instance.new("ScreenGui")
	gui.Name = "AdminNotifications"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = 1000
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = playerGui

	local holder = Instance.new("Frame")
	holder.Name = "Holder"
	holder.AnchorPoint = Vector2.new(0.5, 0)
	holder.Position = UDim2.new(0.5, 0, 0, 12)
	holder.Size = UDim2.new(0, 420, 1, 0)
	holder.BackgroundTransparency = 1
	holder.Parent = gui

	local layout = Instance.new("UIListLayout")
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = Enum.VerticalAlignment.Top
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 8)
	layout.Parent = holder

	return holder
end

-- glyphs per type (swap for image icons later if you want crisper ones)
local ICONS = { success = "✓", error = "✕", warning = "!", info = "i" }
local function iconFor(t) return ICONS[(t or "info"):lower()] or "i" end
local function titleCase(s) s = (s or "info"):lower() return s:sub(1, 1):upper() .. s:sub(2) end

-- opts: { glyph, title, message, accent (Color3), label?, duration? }
function Notify.showRaw(opts)
	local holder = getHolder()

	local existing = {}
	for _, c in ipairs(holder:GetChildren()) do
		if c:IsA("CanvasGroup") then table.insert(existing, c) end
	end
	while #existing >= Notify.MaxOnScreen do
		local oldest = table.remove(existing, 1)
		if oldest then oldest:Destroy() end
	end

	local accent = opts.accent

	local card = Instance.new("CanvasGroup")
	card.Name = "Notification"
	card.Size = UDim2.new(1, 0, 0, 0)
	card.AutomaticSize = Enum.AutomaticSize.Y
	card.BackgroundColor3 = Notify.CardColor
	card.GroupTransparency = 1
	card.LayoutOrder = os.clock() % 1e6
	card.Parent = holder

	local scale = Instance.new("UIScale")
	scale.Scale = 0.96
	scale.Parent = card

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = card

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.Transparency = 0.92
	stroke.Thickness = 1
	stroke.Parent = card

	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 14)
	pad.PaddingBottom = UDim.new(0, 14)
	pad.PaddingLeft = UDim.new(0, 16)
	pad.PaddingRight = UDim.new(0, 16)
	pad.Parent = card

	local row = Instance.new("UIListLayout")
	row.FillDirection = Enum.FillDirection.Horizontal
	row.VerticalAlignment = Enum.VerticalAlignment.Center
	row.SortOrder = Enum.SortOrder.LayoutOrder
	row.Padding = UDim.new(0, 12)
	row.Parent = card

	-- icon badge (soft-tinted circle with a ring)
	local badge = Instance.new("Frame")
	badge.LayoutOrder = 1
	badge.Size = UDim2.new(0, 36, 0, 36)
	badge.BackgroundColor3 = accent
	badge.BackgroundTransparency = 0.82
	badge.Parent = card

	local badgeCorner = Instance.new("UICorner")
	badgeCorner.CornerRadius = UDim.new(1, 0)
	badgeCorner.Parent = badge

	local badgeStroke = Instance.new("UIStroke")
	badgeStroke.Color = accent
	badgeStroke.Transparency = 0.5
	badgeStroke.Thickness = 1.5
	badgeStroke.Parent = badge

	local glyph = Instance.new("TextLabel")
	glyph.Size = UDim2.new(1, 0, 1, 0)
	glyph.BackgroundTransparency = 1
	glyph.Font = Enum.Font.GothamBold
	glyph.Text = opts.glyph
	glyph.TextSize = 18
	glyph.TextColor3 = accent
	glyph.Parent = badge

	-- text column
	local column = Instance.new("Frame")
	column.LayoutOrder = 2
	column.Size = UDim2.new(1, -48, 0, 0) -- fills width after 36 badge + 12 gap
	column.AutomaticSize = Enum.AutomaticSize.Y
	column.BackgroundTransparency = 1
	column.Parent = card

	local col = Instance.new("UIListLayout")
	col.SortOrder = Enum.SortOrder.LayoutOrder
	col.Padding = UDim.new(0, 1)
	col.Parent = column

	-- optional overline (the app label, e.g. ADMINPANEL)
	if opts.label and opts.label ~= "" then
		local overline = Instance.new("TextLabel")
		overline.LayoutOrder = 1
		overline.Size = UDim2.new(1, 0, 0, 0)
		overline.AutomaticSize = Enum.AutomaticSize.Y
		overline.BackgroundTransparency = 1
		overline.Font = Enum.Font.GothamBold
		overline.Text = tostring(opts.label):upper()
		overline.TextSize = 11
		overline.TextColor3 = accent
		overline.TextXAlignment = Enum.TextXAlignment.Left
		overline.Parent = column
	end

	local body = Instance.new("TextLabel")
	body.LayoutOrder = 3
	body.Size = UDim2.new(1, 0, 0, 0)
	body.AutomaticSize = Enum.AutomaticSize.Y
	body.BackgroundTransparency = 1
	body.RichText = true
	body.TextWrapped = true
	body.Font = Enum.Font.GothamMedium
	body.Text = opts.message
	body.TextSize = 14
	body.TextColor3 = Notify.BodyColor
	body.TextXAlignment = Enum.TextXAlignment.Left
	body.TextYAlignment = Enum.TextYAlignment.Top
	body.Visible = opts.message ~= nil and opts.message ~= ""
	body.Parent = column

	local inInfo = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenService:Create(card, inInfo, { GroupTransparency = 0 }):Play()
	TweenService:Create(scale, inInfo, { Scale = 1 }):Play()

	task.delay(opts.duration or Notify.Duration, function()
		if not card.Parent then return end
		local outInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		local t = TweenService:Create(card, outInfo, { GroupTransparency = 1 })
		TweenService:Create(scale, outInfo, { Scale = 0.96 }):Play()
		t:Play()
		t.Completed:Wait()
		card:Destroy()
	end)
end

function Notify.show(data)
	local typeName = data.messageType or "INFO"
	local color = utils:getColorOfType(typeName)
	local message = utils:escapeRichText(data.message) or ""

	Notify.showRaw({
		glyph = iconFor(typeName),
		title = titleCase(typeName),   -- "Success", "Error", ...
		message = message,
		accent = color,
		label = data.label,            -- overline, omit if nil
		duration = data.duration,
	})
end

return Notify