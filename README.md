# 🎮 Domi Studios — Obby

Primer juego de Roblox de **Domi Studios**: un *obby* (parkour por etapas) con guardado de progreso, monedas, tienda y monetización lista para generar Robux.

## 📚 Empieza aquí

1. [`docs/01-PLAN-DE-NEGOCIO.md`](docs/01-PLAN-DE-NEGOCIO.md) — cómo se gana dinero en Roblox, mercado, competencia, precios y métricas.
2. [`docs/02-GUIA-PASO-A-PASO.md`](docs/02-GUIA-PASO-A-PASO.md) — de 0 a juego publicado, fase por fase.

## ✅ Qué ya trae el juego

| Sistema | Archivo | Qué hace |
|---|---|---|
| Configuración | `src/shared/Config.luau` | Precios, IDs de la tienda, recompensas. **El único archivo que hay que editar.** |
| Guardado | `src/server/DataService.luau` | Guarda monedas, etapa y compras (con reintentos y autoguardado) |
| Etapas | `src/server/StageService.luau` | Checkpoints, lava, reaparecer en tu etapa, saltar etapa |
| Monedas | `src/server/CoinService.luau` | Monedas que giran, se recogen y reaparecen (x2 con el pase) |
| Monetización | `src/server/MonetizationService.luau` | Game Passes (VIP, x2) y Developer Products (saltar etapa, monedas) con recibos seguros |
| Tienda | `src/client/Shop.client.luau` | Botón 🛒 y ventana de tienda con precios reales |

## 🗂️ Estructura (Rojo)

```
default.project.json   → mapa de carpetas para Rojo
src/shared  → ReplicatedStorage.Shared
src/server  → ServerScriptService.Server
src/client  → StarterPlayer.StarterPlayerScripts.Client
```

El mapa (etapas, lava, monedas) se construye en Roblox Studio dentro de `Workspace` con las carpetas `Checkpoints`, `Lava` y `Coins`. Ver la guía.

## 🚀 Uso rápido

```bash
rokit install   # instala Rojo (una vez)
rojo serve      # sincroniza el código con Studio
```
