local Menu = {}

function Menu:enter()
    self.t = 0
    self.opciones = {
        { texto = "Jugar (1 jugador)",  accion = "play1" },
        { texto = "Jugar (2 jugadores)", accion = "play2" },
        { texto = "Salir",               accion = "quit" },
    }
    self.seleccion = 1
end

function Menu:update(dt)
    self.t = self.t + dt
end

function Menu:keypressed(key)
    if key == "up" or key == "w" then
        self.seleccion = self.seleccion - 1
        if self.seleccion < 1 then self.seleccion = #self.opciones end
    elseif key == "down" or key == "s" then
        self.seleccion = self.seleccion + 1
        if self.seleccion > #self.opciones then self.seleccion = 1 end
    elseif key == "return" or key == "space" then
        local accion = self.opciones[self.seleccion].accion
        if accion == "play1" then
            self.machine:switch("play", 1)
        elseif accion == "play2" then
            self.machine:switch("play", 2)
        elseif accion == "quit" then
            love.event.quit()
        end
    end
end

function Menu:draw()
    local w, h = love.graphics.getDimensions()
    local pulso = 0.9 + 0.1 * math.sin(self.t * 3)

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("MI MAQUINOLA GAME", 0, 100, w, "center")

    for i, op in ipairs(self.opciones) do
        if i == self.seleccion then
            love.graphics.setColor(1, 0.85, 0.2)
        else
            love.graphics.setColor(1, 1, 1)
        end
        love.graphics.printf(op.texto, 0, 250 + i * 40, w, "center")
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("↑↓ para mover · ENTER para elegir",
        0, h - 40, w, "center")
end

return Menu