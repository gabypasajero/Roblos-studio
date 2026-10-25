--[[
	CONFIGURACIÓN DEL JUEGO
	Este es el único archivo que Domi necesita tocar para ajustar el juego.

	IDs de Game Passes y Developer Products:
	1. Publica el juego (Archivo > Publicar en Roblox).
	2. Ve a create.roblox.com > tu experiencia > Monetización.
	3. Crea cada pase/producto y copia su ID (número) aquí abajo.
	Mientras el ID sea 0, la tienda muestra el botón pero avisa que falta configurarlo.
]]

local Config = {}

-- Nombre del DataStore donde se guarda el progreso. Si lo cambias, todos empiezan de cero.
Config.DataStoreName = "ObbyDomi_v1"

-- Monedas
Config.CoinValue = 1 -- monedas por cada moneda recogida
Config.CoinRespawnSeconds = 20 -- segundos para que una moneda reaparezca
Config.StageReward = 5 -- monedas por llegar a una etapa nueva

-- Velocidad
Config.DefaultWalkSpeed = 16
Config.VipWalkSpeed = 22

-- Game Passes: se compran UNA vez y son para siempre.
Config.GamePasses = {
	VIP = {
		id = 0,
		name = "VIP 👑",
		description = "Corre más rápido y lleva una etiqueta dorada",
	},
	DoubleCoins = {
		id = 0,
		name = "Monedas x2 💰",
		description = "Gana el doble de monedas para siempre",
	},
}

-- Developer Products: se pueden comprar MUCHAS veces.
Config.Products = {
	SkipStage = {
		id = 0,
		name = "Saltar etapa ⏭️",
		description = "Pasa a la siguiente etapa al instante",
	},
	Coins100 = {
		id = 0,
		name = "100 monedas",
		description = "Paquete pequeño de monedas",
		coins = 100,
	},
	Coins500 = {
		id = 0,
		name = "500 monedas",
		description = "¡El mejor valor!",
		coins = 500,
	},
}

return Config
