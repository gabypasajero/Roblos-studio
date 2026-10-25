-- Punto de entrada del servidor: arranca todos los sistemas del juego.

local DataService = require(script.Parent.DataService)
local MonetizationService = require(script.Parent.MonetizationService)
local StageService = require(script.Parent.StageService)
local CoinService = require(script.Parent.CoinService)

MonetizationService.SkipStage = StageService.SkipStage

DataService.Start()
StageService.Start()
CoinService.Start()
MonetizationService.Start()

print("✅ Obby de Domi listo. Etapas encontradas:", StageService.GetMaxStage())
