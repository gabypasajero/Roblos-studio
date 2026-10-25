--[[
	MonetizationService: Game Passes (VIP, Monedas x2) y Developer Products
	(Saltar etapa, paquetes de monedas). Aquí es donde se gana Robux.
]]

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local Config = require(game:GetService("ReplicatedStorage").Shared.Config)
local DataService = require(script.Parent.DataService)

local MonetizationService = {}

-- Se asigna desde Main para evitar dependencias circulares.
MonetizationService.SkipStage = nil :: ((Player) -> boolean)?

local function passKeyFromId(passId: number): string?
	for key, pass in Config.GamePasses do
		if pass.id == passId then
			return key
		end
	end
	return nil
end

function MonetizationService.HasPass(player: Player, key: string): boolean
	return player:GetAttribute("Pass_" .. key) == true
end

local function applyVip(player: Player)
	local character = player.Character
	if not character or not MonetizationService.HasPass(player, "VIP") then
		return
	end
	local humanoid = character:WaitForChild("Humanoid") :: Humanoid
	humanoid.WalkSpeed = Config.VipWalkSpeed

	local head = character:WaitForChild("Head")
	if head:FindFirstChild("VipTag") then
		return
	end
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "VipTag"
	billboard.Size = UDim2.fromOffset(100, 30)
	billboard.StudsOffset = Vector3.new(0, 2.5, 0)
	billboard.AlwaysOnTop = true
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = "👑 VIP"
	label.TextColor3 = Color3.fromRGB(255, 215, 0)
	label.TextStrokeTransparency = 0
	label.TextScaled = true
	label.Font = Enum.Font.FredokaOne
	label.Parent = billboard
	billboard.Parent = head
end

local function grantPass(player: Player, key: string)
	player:SetAttribute("Pass_" .. key, true)
	if key == "VIP" then
		task.spawn(applyVip, player)
	end
end

local function loadPasses(player: Player)
	for key, pass in Config.GamePasses do
		if pass.id ~= 0 then
			local ok, owns = pcall(MarketplaceService.UserOwnsGamePassAsync, MarketplaceService, player.UserId, pass.id)
			if ok and owns then
				grantPass(player, key)
			end
		end
	end
	player.CharacterAdded:Connect(function()
		applyVip(player)
	end)
	applyVip(player)
end

local function grantProduct(player: Player, productId: number): boolean
	for key, product in Config.Products do
		if product.id == productId then
			if key == "SkipStage" then
				local skipped = MonetizationService.SkipStage ~= nil and MonetizationService.SkipStage(player)
				if not skipped then
					-- Ya está en la última etapa: le damos monedas para que la compra no se pierda.
					DataService.AddCoins(player, 50)
				end
				return true
			elseif product.coins then
				DataService.AddCoins(player, product.coins)
				return true
			end
		end
	end
	warn("[Monetization] Producto desconocido:", productId)
	return false
end

-- Roblox llama a esta función cada vez que alguien compra un Developer Product.
-- Debe ser segura de repetir: solo devolvemos PurchaseGranted cuando la compra quedó guardada.
local function processReceipt(receipt)
	local player = Players:GetPlayerByUserId(receipt.PlayerId)
	if not player or not DataService.Get(player) then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	if not DataService.HasReceipt(player, receipt.PurchaseId) then
		if not grantProduct(player, receipt.ProductId) then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
		DataService.AddReceipt(player, receipt.PurchaseId)
	end

	if DataService.Save(player) then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
	return Enum.ProductPurchaseDecision.NotProcessedYet
end

function MonetizationService.Start()
	MarketplaceService.ProcessReceipt = processReceipt

	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, passId, purchased)
		local key = passKeyFromId(passId)
		if purchased and key then
			grantPass(player, key)
		end
	end)

	Players.PlayerAdded:Connect(loadPasses)
	for _, player in Players:GetPlayers() do
		task.spawn(loadPasses, player)
	end
end

return MonetizationService
