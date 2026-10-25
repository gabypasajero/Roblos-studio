-- Tienda: botón en pantalla que abre una ventana con los Game Passes y Developer Products.

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local player = Players.LocalPlayer

local COLORS = {
	background = Color3.fromRGB(30, 30, 46),
	card = Color3.fromRGB(49, 50, 68),
	accent = Color3.fromRGB(250, 179, 135),
	buy = Color3.fromRGB(166, 227, 161),
	text = Color3.fromRGB(255, 255, 255),
}

local function corner(parent: Instance, radius: number)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = parent
end

local gui = Instance.new("ScreenGui")
gui.Name = "ShopGui"
gui.ResetOnSpawn = false

local openButton = Instance.new("TextButton")
openButton.Size = UDim2.fromOffset(140, 50)
openButton.Position = UDim2.new(0, 16, 0.5, -25)
openButton.BackgroundColor3 = COLORS.accent
openButton.Text = "🛒 Tienda"
openButton.TextScaled = true
openButton.Font = Enum.Font.FredokaOne
openButton.TextColor3 = COLORS.background
openButton.Parent = gui
corner(openButton, 12)

local window = Instance.new("Frame")
window.Size = UDim2.fromScale(0.5, 0.7)
window.AnchorPoint = Vector2.new(0.5, 0.5)
window.Position = UDim2.fromScale(0.5, 0.5)
window.BackgroundColor3 = COLORS.background
window.Visible = false
window.Parent = gui
corner(window, 16)

local sizeLimit = Instance.new("UISizeConstraint")
sizeLimit.MinSize = Vector2.new(300, 300)
sizeLimit.MaxSize = Vector2.new(600, 700)
sizeLimit.Parent = window

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 0, 50)
title.Position = UDim2.fromOffset(16, 8)
title.BackgroundTransparency = 1
title.Text = "Tienda"
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextScaled = true
title.Font = Enum.Font.FredokaOne
title.TextColor3 = COLORS.text
title.Parent = window

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.fromOffset(40, 40)
closeButton.Position = UDim2.new(1, -52, 0, 12)
closeButton.BackgroundColor3 = COLORS.card
closeButton.Text = "X"
closeButton.TextScaled = true
closeButton.Font = Enum.Font.FredokaOne
closeButton.TextColor3 = COLORS.text
closeButton.Parent = window
corner(closeButton, 8)

local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(1, -32, 1, -80)
list.Position = UDim2.fromOffset(16, 66)
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.ScrollBarThickness = 6
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.CanvasSize = UDim2.new()
list.Parent = window

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = list

local order = 0
local function addItem(item, isPass: boolean, passKey: string?)
	order += 1

	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, -8, 0, 70)
	card.BackgroundColor3 = COLORS.card
	card.LayoutOrder = order
	card.Parent = list
	corner(card, 10)

	local name = Instance.new("TextLabel")
	name.Size = UDim2.new(0.65, -12, 0.5, 0)
	name.Position = UDim2.fromOffset(12, 4)
	name.BackgroundTransparency = 1
	name.Text = item.name
	name.TextXAlignment = Enum.TextXAlignment.Left
	name.TextScaled = true
	name.Font = Enum.Font.FredokaOne
	name.TextColor3 = COLORS.text
	name.Parent = card

	local description = Instance.new("TextLabel")
	description.Size = UDim2.new(0.65, -12, 0.4, 0)
	description.Position = UDim2.new(0, 12, 0.5, 0)
	description.BackgroundTransparency = 1
	description.Text = item.description
	description.TextXAlignment = Enum.TextXAlignment.Left
	description.TextScaled = true
	description.Font = Enum.Font.Gotham
	description.TextColor3 = COLORS.text
	description.TextTransparency = 0.3
	description.Parent = card

	local buy = Instance.new("TextButton")
	buy.Size = UDim2.new(0.35, -12, 1, -16)
	buy.Position = UDim2.new(0.65, 0, 0, 8)
	buy.BackgroundColor3 = COLORS.buy
	buy.Text = "Comprar"
	buy.TextScaled = true
	buy.Font = Enum.Font.FredokaOne
	buy.TextColor3 = COLORS.background
	buy.Parent = card
	corner(buy, 8)

	-- Muestra el precio real en Robux
	if item.id ~= 0 then
		task.spawn(function()
			local infoType = if isPass then Enum.InfoType.GamePass else Enum.InfoType.Product
			local ok, info = pcall(MarketplaceService.GetProductInfo, MarketplaceService, item.id, infoType)
			if ok and info and info.PriceInRobux then
				buy.Text = "R$ " .. info.PriceInRobux
			end
		end)
	end

	if passKey then
		local function refresh()
			if player:GetAttribute("Pass_" .. passKey) then
				buy.Text = "✔ Tuyo"
				buy.AutoButtonColor = false
				buy.BackgroundColor3 = COLORS.accent
			end
		end
		player:GetAttributeChangedSignal("Pass_" .. passKey):Connect(refresh)
		refresh()
	end

	buy.Activated:Connect(function()
		if item.id == 0 then
			warn("Falta poner el ID de '" .. item.name .. "' en Config.luau")
			return
		end
		if passKey and player:GetAttribute("Pass_" .. passKey) then
			return
		end
		if isPass then
			MarketplaceService:PromptGamePassPurchase(player, item.id)
		else
			MarketplaceService:PromptProductPurchase(player, item.id)
		end
	end)
end

for key, pass in Config.GamePasses do
	addItem(pass, true, key)
end
for _, product in Config.Products do
	addItem(product, false, nil)
end

openButton.Activated:Connect(function()
	window.Visible = not window.Visible
end)
closeButton.Activated:Connect(function()
	window.Visible = false
end)

gui.Parent = player:WaitForChild("PlayerGui")
