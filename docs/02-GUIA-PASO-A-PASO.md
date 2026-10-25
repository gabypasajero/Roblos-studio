# Guía paso a paso — de 0 a juego publicado

Pensada para hacerla **juntos** (adulto + Domi). Cada fase dice quién lidera.

---

## FASE 0 — Preparar todo (1 día) · lidera el adulto

1. **Cuentas**
   - Cuenta de Roblox del adulto (será dueña del grupo y de los pagos).
   - Cuenta de Domi con controles parentales revisados.
2. **Crear el Grupo** (create.roblox.com o roblox.com → Grupos → Crear). Cuesta 100 Robux.
   - Nombre sugerido: **"Domi Studios"** (o el que ella elija).
   - Agrega a Domi y dale un rol con permisos para **editar experiencias del grupo**.
3. **Instalar Roblox Studio** en la computadora: https://create.roblox.com → "Comenzar a crear".
4. *(Opcional, para trabajar con este repositorio)* Instalar **Rojo**, que sincroniza los archivos de código de aquí con Studio:
   - Plugin de Rojo dentro de Studio (pestaña Plugins → buscar "Rojo").
   - Programa de Rojo en la compu: con [Rokit](https://github.com/rojo-rbx/rokit) (`rokit install` en esta carpeta) o descargándolo desde https://rojo.space.

## FASE 1 — Crear el mapa (1–2 semanas) · lidera Domi

1. En Studio: **Archivo → Nuevo → Baseplate**.
2. **Guárdalo en el grupo**: Archivo → Publicar en Roblox → elegir el grupo "Domi Studios" como creador.
3. En el panel **Explorer**, dentro de `Workspace`, crea 3 carpetas (clic derecho → Insertar objeto → Folder):

   | Carpeta | Qué va dentro |
   |---|---|
   | `Checkpoints` | Parts llamadas `1`, `2`, `3`… Una al inicio de cada etapa. La `1` es la salida. |
   | `Lava` | Todo lo que mata al tocarlo (pisos rojos, láseres, sierras…). |
   | `Coins` | Parts doradas (cilindro) que dan monedas. |

4. **Construir las etapas** entre checkpoint y checkpoint. Tips de diseño para Domi:
   - Etapas 1–5 **muy fáciles** (si el jugador muere mucho al inicio, se va).
   - Subir la dificultad poco a poco; cada 5 etapas una "etapa descanso".
   - Usar `Anchored = true` en TODAS las piezas (si no, se caen).
   - Colores por mundo: etapas 1–10 un tema, 11–20 otro.
   - Meta del MVP: **20–30 etapas**.
   - Probar con el botón ▶ **Jugar** seguido.

## FASE 2 — Agregar el código (1 tarde) · lidera el adulto

**Opción A — con Rojo (recomendada):**
```bash
rojo serve
```
En Studio: Plugins → Rojo → **Connect**. El código aparece solo en su lugar.

**Opción B — copiar y pegar (sin instalar nada):**

| Archivo del repo | Dónde crearlo en Studio | Tipo |
|---|---|---|
| `src/shared/Config.luau` | ReplicatedStorage → Folder `Shared` → `Config` | ModuleScript |
| `src/server/DataService.luau` | ServerScriptService → Folder `Server` → `DataService` | ModuleScript |
| `src/server/StageService.luau` | ServerScriptService → `Server` → `StageService` | ModuleScript |
| `src/server/CoinService.luau` | ServerScriptService → `Server` → `CoinService` | ModuleScript |
| `src/server/MonetizationService.luau` | ServerScriptService → `Server` → `MonetizationService` | ModuleScript |
| `src/server/Main.server.luau` | ServerScriptService → `Server` → `Main` | Script |
| `src/client/Shop.client.luau` | StarterPlayer → StarterPlayerScripts → `Shop` | LocalScript |

Luego activa el guardado: **Inicio → Configuración del juego → Seguridad → "Habilitar acceso de Studio a los servicios de API"** ✅.

Prueba con ▶ Jugar: en la Salida (Output) debe aparecer `✅ Obby de Domi listo. Etapas encontradas: N`.

## FASE 3 — Monetización (1 hora) · juntos

1. Ve a **create.roblox.com → Creaciones → (grupo) → tu experiencia → Monetización**.
2. Crea los **Pases** (Passes): `VIP`, `Monedas x2`. Ponles imagen y precio (ver plan de negocio).
3. Crea los **Productos para desarrolladores**: `Saltar etapa`, `100 monedas`, `500 monedas`.
4. Copia cada **ID** y pégalo en `src/shared/Config.luau` donde dice `id = 0`.
5. Publica de nuevo. Prueba las compras en Studio (en Studio son simuladas, **no cobran**).

## FASE 4 — Lanzamiento (1 día) · juntos

- [ ] **Ícono** 512×512: personaje + texto grande ("OBBY DE DULCES 🍭"). Es lo que más afecta las visitas.
- [ ] **3–5 thumbnails** 1920×1080 mostrando lo mejor del juego.
- [ ] **Nombre** con palabras que la gente busca: "Obby", "Easy", "Parkour" + la temática.
- [ ] **Descripción** corta con emojis y lista de novedades.
- [ ] **Cuestionario de madurez** (obligatorio) en la configuración del juego.
- [ ] Dispositivos: Computadora, Teléfono, Tableta, Consola ✅.
- [ ] Hacer el juego **Público**.
- [ ] Invitar a amigos a jugar el primer día (los primeros jugadores ayudan al algoritmo).

## FASE 5 — Crecer (continuo)

| Frecuencia | Acción |
|---|---|
| Semanal | Agregar 5 etapas nuevas + anunciar en la descripción "🆕 Actualización" |
| Semanal | Revisar Analytics: ¿en qué etapa abandona la gente? → hacerla más fácil |
| Mensual | Probar un ícono nuevo (pruebas A/B de miniaturas en el Dashboard) |
| Cuando D1 > 15 % | Invertir en anuncios patrocinados (Ads Manager) con presupuesto pequeño |
| A los 2–3 meses | Juego #2 (Tycoon o Simulator) reutilizando DataService y MonetizationService |

## Ideas de próximas mejoras (backlog)

- 🌈 **Trails / estelas** compradas con monedas (las monedas necesitan en qué gastarse).
- 🏆 **Tabla de clasificación global** (OrderedDataStore) de quién llegó más lejos.
- 🎁 **Recompensa diaria** por entrar cada día (sube la retención).
- ⏱️ **Modo speedrun** con cronómetro.
- 🎵 **Música por mundo**.
- 👥 **Invitar amigos → recompensa** (crecimiento orgánico).
- 🐾 **Mascota que te sigue** (gancho para el futuro Simulator).
