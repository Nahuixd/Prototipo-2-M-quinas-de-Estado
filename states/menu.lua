local Menu = {}

function Menu:enter()
    self.t = 0
    self.opciones = {
        { texto = "Jugar (1 jugador)",   accion = "play1" },
        { texto = "Jugar (2 jugadores)", accion = "play2" },
        { texto = "Salir",               accion = "quit" },
    }
    self.seleccion = 1

    audio.playMusic("assets/menu.wav")           -- 🎵 música de menú
end

function Menu:update(dt)
    self.t = self.t + dt
end

function Menu:keypressed(key)
    if key == "up" or key == "w" then
        self.seleccion = self.seleccion - 1
        if self.seleccion < 1 then self.seleccion = #self.opciones end
        audio.playSFX("select", 0.05)

    elseif key == "down" or key == "s" then
        self.seleccion = self.seleccion + 1
        if self.seleccion > #self.opciones then self.seleccion = 1 end
        audio.playSFX("select", 0.05)

    elseif key == "return" or key == "space" then
        audio.playSFX("select", 0.1)
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
        0, h - 60, w, "center")

    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.printf("M: mute · +/-: volumen",
        0, h - 30, w, "center")
    love.graphics.setColor(1, 1, 1)
end

return Menu