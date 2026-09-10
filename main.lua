local StateMachine = require("statemachine")
local Camera       = require("camera")

local Menu     = require("states.menu")
local Play     = require("states.play")
local Pause    = require("states.pause")
local GameOver = require("states.gameover")

-- Exponemos Camera como global para que los estados la usen sin requires repetidos
_G.Camera = Camera

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

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setBackgroundColor(0.08, 0.09, 0.12)
    love.math.setRandomSeed(os.time())

    -- Assets compartidos globalmente
    _G.IMG_PLAYER = cargarImagen("assets/player.png", 0.35, 0.75, 1.0, 32, 32)
    _G.IMG_COIN   = cargarImagen("assets/coin.png",   1.0,  0.85, 0.2, 20, 20)

    -- Máquina de estados
    machine = StateMachine.new()
    machine:add("menu",     Menu)
    machine:add("play",     Play)
    machine:add("pause",    Pause)
    machine:add("gameover", GameOver)

    machine:switch("menu")
end

function love.update(dt)
    machine:update(dt)
end

function love.draw()
    machine:draw()
end

function love.keypressed(key)
    machine:keypressed(key)
end

function love.keyreleased(key)
    machine:keyreleased(key)
end