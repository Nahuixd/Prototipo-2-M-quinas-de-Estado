local GameOver = {}

function GameOver:enter(jugadores)
    self.jugadores = jugadores
    self.t = 0
end

function GameOver:update(dt)
    self.t = self.t + dt
end

function GameOver:keypressed(key)
    if key == "return" or key == "space" then
        self.machine:switch("menu")
    elseif key == "r" then
        self.machine:switch("play", #self.jugadores)
    end
end

function GameOver:draw()
    local w, h = love.graphics.getDimensions()

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("¡FIN DE PARTIDA!", 0, 150, w, "center")

    local y = 250
    for i, p in ipairs(self.jugadores) do
        love.graphics.printf("Jugador " .. i .. ": " .. p.score,
            0, y, w, "center")
        y = y + 30
    end

    love.graphics.setColor(1, 0.85, 0.2)
    love.graphics.printf("ENTER para volver al menú · R para reintentar",
        0, h - 60, w, "center")
end

return GameOver