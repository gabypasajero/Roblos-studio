--[[
	DataService: guarda y carga el progreso de cada jugador (monedas, etapa, compras).
	Para que funcione en Studio: Configuración del juego > Seguridad > activar
	"Permitir que Studio acceda a los servicios de API".
]]

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Config = require(game:GetService("ReplicatedStorage").Shared.Config)

local MAX_RECEIPTS = 100
local AUTOSAVE_SECONDS = 120

local store = DataStoreService:GetDataStore(Config.DataStoreName)
local sessions: { [Player]: any } = {}

local DataService = {}

local function defaultData()
	return {
		coins = 0,
		stage = 1,
		receipts = {}, -- IDs de compras ya entregadas (evita entregar dos veces)
	}
end

local function keyFor(player: Player): string
	return "player_" .. player.UserId
end

-- Reintenta una llamada al DataStore hasta 3 veces.
local function retry(fn: () -> any): (boolean, any)
	local ok, result
	for attempt = 1, 3 do
		ok, result = pcall(fn)
		if ok then
			return true, result
		end
		warn(("[DataService] intento %d falló: %s"):format(attempt, tostring(result)))
		task.wait(attempt)
	end
	return false, result
end

local function createLeaderstats(player: Player, data)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"

	local stage = Instance.new("IntValue")
	stage.Name = "Etapa"
	stage.Value = data.stage
	stage.Parent = leaderstats

	local coins = Instance.new("IntValue")
	coins.Name = "Monedas"
	coins.Value = data.coins
	coins.Parent = leaderstats

	leaderstats.Parent = player
end

local function syncLeaderstats(player: Player)
	local data = sessions[player]
	local leaderstats = player:FindFirstChild("leaderstats")
	if not data or not leaderstats then
		return
	end
	leaderstats.Etapa.Value = data.stage
	leaderstats.Monedas.Value = data.coins
end

function DataService.Load(player: Player)
	local ok, saved = retry(function()
		return store:GetAsync(keyFor(player))
	end)

	if not ok then
		-- Mejor sacar al jugador que dejarlo jugar y sobrescribir su progreso real.
		player:Kick("No pudimos cargar tu progreso. Por favor vuelve a entrar.")
		return
	end

	local data = defaultData()
	if type(saved) == "table" then
		for key, value in saved do
			data[key] = value
		end
	end

	if not player.Parent then
		return -- se fue mientras cargaba
	end
	sessions[player] = data
	createLeaderstats(player, data)
	player:SetAttribute("DataLoaded", true)
end

function DataService.Save(player: Player): boolean
	local data = sessions[player]
	if not data then
		return false
	end
	local ok = retry(function()
		store:SetAsync(keyFor(player), data, { player.UserId })
	end)
	return ok
end

-- Devuelve la tabla de datos del jugador (o nil si aún no cargó).
function DataService.Get(player: Player)
	return sessions[player]
end

-- Espera a que el jugador termine de cargar (máximo 30 s).
function DataService.WaitFor(player: Player)
	local start = os.clock()
	while not sessions[player] and player.Parent and os.clock() - start < 30 do
		task.wait(0.1)
	end
	return sessions[player]
end

function DataService.AddCoins(player: Player, amount: number)
	local data = sessions[player]
	if not data then
		return
	end
	data.coins += amount
	syncLeaderstats(player)
end

function DataService.SetStage(player: Player, stage: number)
	local data = sessions[player]
	if not data then
		return
	end
	data.stage = stage
	syncLeaderstats(player)
end

function DataService.HasReceipt(player: Player, purchaseId: string): boolean
	local data = sessions[player]
	return data ~= nil and table.find(data.receipts, purchaseId) ~= nil
end

function DataService.AddReceipt(player: Player, purchaseId: string)
	local data = sessions[player]
	if not data then
		return
	end
	table.insert(data.receipts, purchaseId)
	while #data.receipts > MAX_RECEIPTS do
		table.remove(data.receipts, 1)
	end
end

function DataService.Start()
	Players.PlayerAdded:Connect(DataService.Load)
	for _, player in Players:GetPlayers() do
		task.spawn(DataService.Load, player)
	end

	Players.PlayerRemoving:Connect(function(player)
		DataService.Save(player)
		sessions[player] = nil
	end)

	-- Guardado automático
	task.spawn(function()
		while true do
			task.wait(AUTOSAVE_SECONDS)
			for player in sessions do
				task.spawn(DataService.Save, player)
			end
		end
	end)

	-- Guarda a todos cuando el servidor se apaga
	game:BindToClose(function()
		if RunService:IsStudio() then
			task.wait(1)
		end
		local pending = 0
		for player in sessions do
			pending += 1
			task.spawn(function()
				DataService.Save(player)
				pending -= 1
			end)
		end
		while pending > 0 do
			task.wait()
		end
	end)
end

return DataService
