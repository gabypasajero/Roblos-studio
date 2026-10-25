--[[
	CoinService: monedas para recoger por el mapa.
	Crea una carpeta en Workspace llamada "Coins" y pon dentro Parts (por ejemplo cilindros dorados).
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Config = require(game:GetService("ReplicatedStorage").Shared.Config)
local DataService = require(script.Parent.DataService)
local MonetizationService = require(script.Parent.MonetizationService)

local CoinService = {}

local function setVisible(coin: BasePart, visible: boolean)
	coin.Transparency = if visible then 0 else 1
	coin:SetAttribute("Active", visible)
end

local function setupCoin(coin: BasePart)
	coin.Anchored = true
	coin.CanCollide = false
	setVisible(coin, true)

	-- Giro decorativo
	TweenService:Create(
		coin,
		TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1),
		{ CFrame = coin.CFrame * CFrame.Angles(0, math.rad(180), 0) }
	):Play()

	coin.Touched:Connect(function(hit)
		if not coin:GetAttribute("Active") then
			return
		end
		local character = hit:FindFirstAncestorOfClass("Model")
		local player = character and Players:GetPlayerFromCharacter(character)
		if not player or not DataService.Get(player) then
			return
		end

		setVisible(coin, false)
		local multiplier = if MonetizationService.HasPass(player, "DoubleCoins") then 2 else 1
		DataService.AddCoins(player, Config.CoinValue * multiplier)

		task.delay(Config.CoinRespawnSeconds, setVisible, coin, true)
	end)
end

function CoinService.Start()
	local folder = workspace:FindFirstChild("Coins")
	if not folder then
		return
	end
	for _, coin in folder:GetDescendants() do
		if coin:IsA("BasePart") then
			setupCoin(coin)
		end
	end
end

return CoinService
