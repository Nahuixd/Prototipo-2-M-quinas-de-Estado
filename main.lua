local StateMachine = require("statemachine")
local Camera       = require("camera")
local audio        = require("audio")          -- 🎵 NUEVO

local Menu     = require("states.menu")
local Play     = require("states.play")
local Pause    = require("states.pause")
local GameOver = require("states.gameover")

_G.Camera = Camera
_G.audio  = audio                              -- 🎵 NUEVO: acceso global desde estados

-- ============================================
--  CARGA DEFENSIVA DE IMÁGENES
--  Si el archivo no existe, genera un cuadrado de color
-- ============================================
local function cargarImagen(ruta, r, g, b, w, h)
    if love.filesystem.getInfo(ruta) then
        local img = love.graphics.newImage(ruta)
        img:setFilter("nearest", "nearest")
        return img
    end
    w, h = w or 32, h or 32
    local canvas = love.graphics.newCanvas(w, h)
    love.graphics.setCanvas(canvas)
    love.graphics.clear()
    love.graphics.setColor(r, g, b)
    love.graphics.rectangle("fill", 0, 0, w, h)
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1)
    return canvas
end

-- ============================================
--  LOVE.LOAD
-- ============================================
function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setBackgroundColor(0.08, 0.09, 0.12)
    love.math.setRandomSeed(os.time())

    _G.IMG_PLAYER1 = cargarImagen("assets/frog.png",  0.35, 0.75, 1.0, 32, 32)   -- 🐸 Jugador 1
_G.IMG_PLAYER2 = cargarImagen("assets/mouse.png", 0.9,  0.5,  0.3, 32, 32)   -- 🐭 Jugador 2
_G.IMG_COIN    = cargarImagen("assets/coin.png",  1.0,  0.85, 0.2, 20, 20)   -- 🪙 Moneda

    audio.load()                               -- 🎵 NUEVO: cargar SFX

    machine = StateMachine.new()
    machine:add("menu",     Menu)
    machine:add("play",     Play)
    machine:add("pause",    Pause)
    machine:add("gameover", GameOver)

    machine:switch("menu")
end

-- ============================================
--  LOVE.UPDATE
-- ============================================
function love.update(dt)
    machine:update(dt)
end

-- ============================================
--  LOVE.DRAW
-- ============================================
function love.draw()
    machine:draw()
end

-- ============================================
--  LOVE.KEYPRESSED
-- ============================================
function love.keypressed(key)
    -- 🎵 NUEVO: Atajo global de mute (funciona en cualquier estado)
    if key == "m" then
        audio.toggleMute()
        return
    end

    -- 🎵 NUEVO: Control de volumen global
    if key == "=" or key == "kp+" then
        audio.setMusicVolume(audio.musicVolume + 0.1)
        audio.setSFXVolume(audio.sfxVolume + 0.1)
        print("Volumen: " .. math.floor(audio.musicVolume * 100) .. "%")
        return
    elseif key == "minus" or key == "kp-" then
        audio.setMusicVolume(audio.musicVolume - 0.1)
        audio.setSFXVolume(audio.sfxVolume - 0.1)
        print("Volumen: " .. math.floor(audio.musicVolume * 100) .. "%")
        return
    end

    machine:keypressed(key)
end

-- ============================================
--  LOVE.KEYRELEASED
-- ============================================
function love.keyreleased(key)
    machine:keyreleased(key)
end