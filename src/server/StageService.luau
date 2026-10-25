--[[
	StageService: checkpoints, lava y reaparición.

	Cómo armar las etapas en Studio:
	- Crea una carpeta en Workspace llamada "Checkpoints".
	- Dentro pon Parts con nombre "1", "2", "3"... (el "1" es donde empiezan todos).
	- Crea una carpeta en Workspace llamada "Lava": todo lo que pongas dentro mata al tocarlo.
]]

local Players = game:GetService("Players")

local Config = require(game:GetService("ReplicatedStorage").Shared.Config)
local DataService = require(script.Parent.DataService)

local StageService = {}

local checkpoints: { [number]: BasePart } = {}
local maxStage = 1

local function playerFromHit(hit: BasePart): Player?
	local character = hit:FindFirstAncestorOfClass("Model")
	if not character then
		return nil
	end
	return Players:GetPlayerFromCharacter(character)
end

local function teleportToStage(player: Player)
	local data = DataService.Get(player)
	local character = player.Character
	if not data or not character then
		return
	end
	local checkpoint = checkpoints[data.stage] or checkpoints[1]
	if checkpoint then
		character:PivotTo(checkpoint.CFrame + Vector3.new(0, 4, 0))
	end
end

local function onCheckpointTouched(stage: number, hit: BasePart)
	local player = playerFromHit(hit)
	if not player then
		return
	end
	local data = DataService.Get(player)
	if not data then
		return
	end
	-- Solo se avanza a la etapa siguiente (no se pueden saltar etapas por fuera del juego).
	if stage == data.stage + 1 then
		DataService.SetStage(player, stage)
		DataService.AddCoins(player, Config.StageReward)
	end
end

local function onLavaTouched(hit: BasePart)
	local character = hit:FindFirstAncestorOfClass("Model")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid.Health > 0 then
		humanoid.Health = 0
	end
end

-- Avanza una etapa (usado por el producto "Saltar etapa").
function StageService.SkipStage(player: Player): boolean
	local data = DataService.Get(player)
	if not data or data.stage >= maxStage then
		return false
	end
	DataService.SetStage(player, data.stage + 1)
	teleportToStage(player)
	return true
end

function StageService.GetMaxStage(): number
	return maxStage
end

function StageService.Start()
	local folder = workspace:FindFirstChild("Checkpoints")
	if folder then
		for _, part in folder:GetChildren() do
			local stage = tonumber(part.Name)
			if part:IsA("BasePart") and stage then
				checkpoints[stage] = part
				maxStage = math.max(maxStage, stage)
				part.Touched:Connect(function(hit)
					onCheckpointTouched(stage, hit)
				end)
			end
		end
	else
		warn("[StageService] Falta la carpeta Workspace.Checkpoints")
	end

	local lava = workspace:FindFirstChild("Lava")
	if lava then
		for _, part in lava:GetDescendants() do
			if part:IsA("BasePart") then
				part.Touched:Connect(onLavaTouched)
			end
		end
	end

	local function onPlayer(player: Player)
		player.CharacterAdded:Connect(function(character)
			DataService.WaitFor(player)
			character:WaitForChild("HumanoidRootPart")
			task.wait() -- deja que Roblox termine de colocar al personaje
			teleportToStage(player)
		end)
	end
	Players.PlayerAdded:Connect(onPlayer)
	for _, player in Players:GetPlayers() do
		onPlayer(player)
	end
end

return StageService
