local Player = require("player")
local Coin   = require("coin")
local gen    = require("gen")

-- ============================================================
--  🎨 AJUSTÁ ACÁ LA ESCALA DE CADA COSA
--  1.0 = tamaño original · 0.5 = mitad · 2.0 = doble
-- ============================================================
local ESCALA_JUGADOR = 0.5    -- frog y mouse
local ESCALA_MONEDA  = 0.3    -- coin

local Play = {}

-- cantJugadores: 1 o 2
function Play:enter(cantJugadores)
    -- 🆕 Si ya hay una partida en curso con los mismos jugadores,
    -- estamos volviendo de pausa → NO reiniciar todo
    if self.camaras and self.cantJugadores == cantJugadores then
        audio.playMusic("assets/play.wav")
        return
    end

    self.cantJugadores = cantJugadores or 1
    self.debug         = false

    -- Mundo virtual (donde viven las cosas)
    self.world = { w = 1600, h = 1200 }

    -- Imágenes (main.lua las dejó en _G vía love.load)
    self.imgJugador1 = _G.IMG_PLAYER1      -- 🐸 frog
    self.imgJugador2 = _G.IMG_PLAYER2      -- 🐭 mouse
    self.imgMoneda   = _G.IMG_COIN         -- 🪙 coin

    -- Jugadores
    local cx, cy = self.world.w / 2, self.world.h / 2
    self.jugadores = {}
    self.jugadores[1] = Player.new(cx - 100, cy, self.imgJugador1,
        { up = "w", down = "s", left = "a", right = "d" },
        ESCALA_JUGADOR)
    self.jugadores[1].size = 20 * ESCALA_JUGADOR

    if self.cantJugadores == 2 then
        self.jugadores[2] = Player.new(cx + 100, cy, self.imgJugador2,
            { up = "up", down = "down", left = "left", right = "right" },
            ESCALA_JUGADOR)
        self.jugadores[2].size = 20 * ESCALA_JUGADOR
    end

    -- Cámara por jugador
    self.camaras = {}
    local w, h = love.graphics.getDimensions()
    local mitadW = (self.cantJugadores == 2) and (w / 2) or w
    for i = 1, self.cantJugadores do
        self.camaras[i] = _G.Camera.new(mitadW, h)
        self.camaras[i]:snapTo(self.jugadores[i])
    end

    -- Lienzo para la pantalla dividida
    self.canvas = love.graphics.newCanvas(mitadW, h)

    -- Generación procedural de monedas
    self.coins = {}
    self:generarMonedas(30, cx, cy)

    audio.playMusic("assets/play.wav")           -- 🎵 música de juego
end

function Play:generarMonedas(cantidad, cx, cy)
    local puntos = gen.scatter(cantidad, {
        radius      = 480,
        minDist     = 44,
        maxIntentos = 40,
    })

    for _, p in ipairs(puntos) do
        local c = Coin.new(
            cx + p.x,
            cy + p.y,
            self.imgMoneda,
            ESCALA_MONEDA
        )
        c.size = 10 * ESCALA_MONEDA
        self.coins[#self.coins + 1] = c
    end
end

-- ⚠️ OJO: leave() NO borra nada. Pause:draw() necesita el estado
-- intacto para dibujar el juego pausado de fondo.
function Play:leave()
    -- (intencionalmente vacío)
end

-- Limpieza REAL. Se llama desde Pause cuando el jugador elige
-- "Reiniciar" o "Menú", o al volver al menú principal.
function Play:reset()
    self.coins         = nil
    self.jugadores     = nil
    self.camaras       = nil
    self.canvas        = nil
    self.cantJugadores = nil
    self.imgJugador1   = nil
    self.imgJugador2   = nil
    self.imgMoneda     = nil
    self.world         = nil
end

function Play:update(dt)
    for _, p in ipairs(self.jugadores) do p:update(dt) end

    -- Cada cámara sigue a su jugador correspondiente
    for i, c in ipairs(self.camaras) do
        c:follow(self.jugadores[i], dt)
    end
    for _, c in ipairs(self.camaras) do c:update(dt) end

    -- Colisiones jugador ↔ moneda
    for i = #self.coins, 1, -1 do
        local c = self.coins[i]
        c:update(dt)
        for j, p in ipairs(self.jugadores) do
            if p:collidesWith(c) then
                table.remove(self.coins, i)
                p.score = p.score + 1
                p.size  = p.size + 1
                self.camaras[j]:shake(0.2, 4)        -- shake en SU cámara
                audio.playSFX("coin", 0.15)
                break
            end
        end
    end

    -- Fin de partida
    if #self.coins == 0 then
        self.machine:switch("gameover", self.jugadores)
    end
end

function Play:drawMundo(camara, foco)
    camara:attach()
    for _, c in ipairs(self.coins) do c:draw(self.debug) end
    for _, p in ipairs(self.jugadores) do p:draw(self.debug) end
    camara:detach()
end

function Play:draw()
    local w, h = love.graphics.getDimensions()

    if self.cantJugadores == 1 then
        self:drawMundo(self.camaras[1], self.jugadores[1])
        self:drawHUD(self.jugadores[1], 10, 10)
    else
        local mitadW = w / 2

        love.graphics.setCanvas(self.canvas)
            love.graphics.clear()
            self:drawMundo(self.camaras[1], self.jugadores[1])
        love.graphics.setCanvas()
        love.graphics.draw(self.canvas, 0, 0)

        love.graphics.setCanvas(self.canvas)
            love.graphics.clear()
            self:drawMundo(self.camaras[2], self.jugadores[2])
        love.graphics.setCanvas()
        love.graphics.draw(self.canvas, mitadW, 0)

        -- Línea divisoria
        love.graphics.setColor(1, 1, 1)
        love.graphics.line(mitadW, 0, mitadW, h)

        self:drawHUD(self.jugadores[1], 10, 10)
        self:drawHUD(self.jugadores[2], mitadW + 10, 10)
    end
end

function Play:drawHUD(p, x, y)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Jugador " .. (p.keys.left == "a" and "1" or "2") ..
        " - " .. p.score, x, y)
end

function Play:keypressed(key)
    if key == "escape" then
        self.machine:switch("pause", self)
    elseif key == "f1" then
        self.debug = not self.debug
    end
end

return Play