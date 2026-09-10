local Pause = {}

function Pause:enter(playState)
    self.play = playState
    self.seleccion = 1
    self.opciones = {
        { texto = "Continuar", accion = "resume" },
        { texto = "Reiniciar", accion = "restart" },
        { texto = "Menú",      accion = "menu" },
    }

    -- Bajar música al 20% para sensación de pausa
    self.volumenPrevio = audio.musicVolume
    audio.setMusicVolume(0.2)
end

function Pause:leave()
    -- Restaurar volumen al salir de pausa
    audio.setMusicVolume(self.volumenPrevio or 0.6)
end

function Pause:keypressed(key)
    -- Navegación
    if key == "up" or key == "w" then
        self.seleccion = self.seleccion - 1
        if self.seleccion < 1 then self.seleccion = #self.opciones end
        audio.playSFX("select", 0.05)

    elseif key == "down" or key == "s" then
        self.seleccion = self.seleccion + 1
        if self.seleccion > #self.opciones then self.seleccion = 1 end
        audio.playSFX("select", 0.05)

    -- ESC → atajo rápido para CONTINUAR (sin reset, vuelve al juego tal cual)
    elseif key == "escape" then
        audio.playSFX("select", 0.05)
        self.machine:switch("play", self.play.cantJugadores)

    -- ENTER / SPACE → confirmar opción
    elseif key == "return" or key == "space" then
        audio.playSFX("select", 0.1)
        local accion = self.opciones[self.seleccion].accion

        if accion == "resume" then
            -- Continuar: NO reset, Play:enter() detecta que ya hay partida
            self.machine:switch("play", self.play.cantJugadores)

        elseif accion == "restart" then
            -- Reiniciar: limpiar y volver a entrar (partida fresca)
            local cant = self.play.cantJugadores
            self.play:reset()
            self.machine:switch("play", cant)

        elseif accion == "menu" then
            -- Volver al menú principal
            self.play:reset()
            audio.stopMusic()
            self.machine:switch("menu")
        end

    -- M → atajo rápido al MENÚ
    elseif key == "m" then
        audio.playSFX("select", 0.05)
        self.play:reset()
        audio.stopMusic()
        self.machine:switch("menu")
    end
end

function Pause:draw()
    -- Dibujar el juego pausado de fondo (necesita self.play intacto)
    if self.play then self.play:draw() end

    -- Oscurecer
    local w, h = love.graphics.getDimensions()
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", 0, 0, w, h)

    -- Título
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("PAUSA", 0, 100, w, "center")

    -- Opciones
    for i, op in ipairs(self.opciones) do
        if i == self.seleccion then
            love.graphics.setColor(1, 0.85, 0.2)
        else
            love.graphics.setColor(1, 1, 1)
        end
        love.graphics.printf(op.texto, 0, 250 + i * 40, w, "center")
    end

    -- Ayuda de controles
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.printf("↑↓ mover · ENTER elegir · ESC volver · M menú",
        0, h - 30, w, "center")
    love.graphics.setColor(1, 1, 1)
end

return Pause