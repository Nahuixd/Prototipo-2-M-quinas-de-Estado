local Player = require("player")
local Coin   = require("coin")
local gen    = require("gen")

local Play = {}

-- cantJugadores: 1 o 2
function Play:enter(cantJugadores)
    self.cantJugadores = cantJugadores or 1
    self.debug         = false

    -- Mundo virtual (donde viven las cosas)
    self.world = { w = 1600, h = 1200 }

    -- Imágenes (main.lua las dejó en _G vía love.load)
    self.imgJugador = _G.IMG_PLAYER
    self.imgMoneda  = _G.IMG_COIN

    -- Jugadores
    local cx, cy = self.world.w / 2, self.world.h / 2
    self.jugadores = {}
    self.jugadores[1] = Player.new(cx - 100, cy, self.imgJugador,
        { up = "w", down = "s", left = "a", right = "d" })

    if self.cantJugadores == 2 then
        self.jugadores[2] = Player.new(cx + 100, cy, self.imgJugador,
            { up = "up", down = "down", left = "left", right = "right" })
    end

    -- Cámara por jugador (una cámara por cada mitad de pantalla)
    self.camaras = {}
    local w, h = love.graphics.getDimensions()
    local mitadW = (self.cantJugadores == 2) and (w / 2) or w
    for i = 1, self.cantJugadores do
        self.camaras[i] = _G.Camera.new(mitadW, h)
        self.camaras[i]:snapTo(self.jugadores[i])
    end

    -- Lienzo para la pantalla dividida
    self.canvas = love.graphics.newCanvas(mitadW, h)

    -- ============================================
    --  GENERACIÓN PROCEDURAL DE MONEDAS
    -- ============================================
    self.coins = {}
    self:generarMonedas(30, cx, cy)

    audio.playMusic("assets/play.ogg") --Musica de juego
end

function Play:generarMonedas(cantidad, cx, cy)
    -- gen.scatter devuelve puntos sin superponerse
    local puntos = gen.scatter(cantidad, {
        radius    = 480,
        minDist   = 44,
        maxIntentos = 40,
    })

    for _, p in ipairs(puntos) do
        self.coins[#self.coins + 1] = Coin.new(
            cx + p.x,
            cy + p.y,
            self.imgMoneda
        )
    end
end

function Play:leave()
    -- Limpieza por si volvemos al menú y queremos liberar memoria
    self.coins     = nil
    self.jugadores = nil
    self.camaras   = nil
    self.canvas    = nil
end

function Play:update(dt)
    for _, p in ipairs(self.jugadores) do p:update(dt) end
    for _, c in ipairs(self.camaras)   do c:follow(self.jugadores[1], dt) end
    for i, c in ipairs(self.camaras)   do c:update(dt) end

    -- Colisiones jugador ↔ moneda
    for i = #self.coins, 1, -1 do
        local c = self.coins[i]
        c:update(dt)
        for _, p in ipairs(self.jugadores) do
            if p:collidesWith(c) then
                table.remove(self.coins, i)
                p.score = p.score + 1
                p.size  = p.size + 1
                self.camaras[1]:shake(0.2, 4)
                break
            end
        end
    end

    -- Fin de partida: se acabaron las monedas
    if #self.coins == 0 then
        self.machine:switch("gameover", self.jugadores)
    end
end

-- Dibuja el mundo visto por una cámara
function Play:drawMundo(camara, foco)
    camara:attach()

    for _, c in ipairs(self.coins) do c:draw(self.debug) end
    for _, p in ipairs(self.jugadores) do p:draw(self.debug) end

    camara:detach()
end

function Play:draw()
    local w, h = love.graphics.getDimensions()

    if self.cantJugadores == 1 then
        -- Un solo jugador: cámara en pantalla completa
        self:drawMundo(self.camaras[1], self.jugadores[1])
        self:drawHUD(self.jugadores[1], 10, 10)
    else
        -- Pantalla dividida: mismo canvas, dibujado 2 veces
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

        -- Línea separadora
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