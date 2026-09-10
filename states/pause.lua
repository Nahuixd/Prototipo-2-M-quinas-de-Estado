local Pause = {}

function Pause:enter(playState)
    self.play = playState
    self.seleccion = 1
    self.opciones = {
        { texto = "Continuar", accion = "resume" },
        { texto = "Reiniciar", accion = "restart" },
        { texto = "Menú",      accion = "menu" },
    }

    -- 🎵 NUEVO: bajar música al 20% para sensación de "pausa"
    self.volumenPrevio = audio.musicVolume
    audio.setMusicVolume(0.6)
end

function Pause:leave()
    -- 🎵 NUEVO: restaurar volumen al salir de pausa
    audio.setMusicVolume(self.volumenPrevio or 0.6)
end

function Pause:keypressed(key)
    if key == "up" or key == "w" then
        self.seleccion = self.seleccion - 1
        if self.seleccion < 1 then self.seleccion = #self.opciones end
        audio.playSFX("select", 0.05)          -- 🎵 NUEVO

    elseif key == "down" or key == "s" then
        self.seleccion = self.seleccion + 1
        if self.seleccion > #self.opciones then self.seleccion = 1 end
        audio.playSFX("select", 0.05)          -- 🎵 NUEVO

    elseif key == "escape" then
        audio.playSFX("select", 0.05)          -- 🎵 NUEVO
        self.machine:switch("play", self.play.cantJugadores)

    elseif key == "return" then
        audio.playSFX("select", 0.1)           -- 🎵 NUEVO
        local accion = self.opciones[self.seleccion].accion
        if accion == "resume" then
            self.machine:switch("play", self.play.cantJugadores)
        elseif accion == "restart" then
            self.machine:switch("play", self.play.cantJugadores)
        elseif accion == "menu" then
            self.machine:switch("menu")
        end
    end
end

function Pause:draw()
    -- Dibujamos el juego congelado de fondo
    if self.play then self.play:draw() end

    local w, h = love.graphics.getDimensions()
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", 0, 0, w, h)

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("PAUSA", 0, 100, w, "center")

    for i, op in ipairs(self.opciones) do
        if i == self.seleccion then
            love.graphics.setColor(1, 0.85, 0.2)
        else
            love.graphics.setColor(1, 1, 1)
        end
        love.graphics.printf(op.texto, 0, 250 + i * 40, w, "center")
    end

    love.graphics.setColor(1, 1, 1)
end

return Pause