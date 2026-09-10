local audio = {}

-- ========================================
--  CONFIG
-- ========================================
audio.musicVolume = 0.6
audio.sfxVolume   = 0.8
audio.muted       = false

-- Guardamos la música actual para poder cambiarla o pararla
audio.currentMusic = nil
audio.currentMusicName = nil

-- Pool de sonidos cargados
audio.sfx = {}

-- ========================================
--  CARGA DEFENSIVA
-- ========================================
-- Si el archivo no existe, devuelve nil y avisa (no rompe el juego)
local function cargarSource(ruta, tipo)
    tipo = tipo or "static"
    if love.filesystem.getInfo(ruta) then
        local ok, source = pcall(love.audio.newSource, ruta, tipo)
        if ok then return source end
        print("[audio] Error al cargar: " .. ruta)
    else
        print("[audio] No existe (se ignora): " .. ruta)
    end
    return nil
end

-- Carga todos los SFX al inicio
function audio.load()
    audio.sfx.coin   = cargarSource("assets/coin.wav",   "static")
    audio.sfx.select = cargarSource("assets/select.wav",   "static")
    audio.sfx.hit    = cargarSource("assets/hit.wav",    "static")

    -- Volumen inicial
    for _, s in pairs(audio.sfx) do
        if s then s:setVolume(audio.sfxVolume) end
    end
end

-- ========================================
--  SFX
-- ========================================
function audio.playSFX(nombre, pitchVariacion)
    if audio.muted then return end
    local s = audio.sfx[nombre]
    if not s then return end

    -- Clonar el source permite solapamiento (sonar varias veces juntas)
    local instancia = s:clone()
    instancia:setVolume(audio.sfxVolume)

    if pitchVariacion then
        -- Variación aleatoria de tono para que no suene robótico
        local p = 1 + love.math.random() * pitchVariacion * 2 - pitchVariacion
        instancia:setPitch(p)
    end

    instancia:play()
end

-- ========================================
--  MÚSICA
-- ========================================
-- Cambia la música de fondo. Si es la misma que ya suena, no la reinicia.
function audio.playMusic(ruta, loop)
    if audio.currentMusicName == ruta then return end

    -- Parar la anterior
    audio.stopMusic()

    if not ruta then return end

    local source = cargarSource(ruta, "stream")
    if not source then return end

    source:setLooping(loop ~= false)
    source:setVolume(audio.musicVolume)
    source:play()

    audio.currentMusic = source
    audio.currentMusicName = ruta
end

function audio.stopMusic()
    if audio.currentMusic then
        audio.currentMusic:stop()
        audio.currentMusic = nil
        audio.currentMusicName = nil
    end
end

-- ========================================
--  VOLUMEN / MUTE
-- ========================================
function audio.setMusicVolume(v)
    audio.musicVolume = math.max(0, math.min(1, v))
    if audio.currentMusic then
        audio.currentMusic:setVolume(audio.musicVolume)
    end
end

function audio.setSFXVolume(v)
    audio.sfxVolume = math.max(0, math.min(1, v))
    for _, s in pairs(audio.sfx) do
        if s then s:setVolume(audio.sfxVolume) end
    end
end

function audio.toggleMute()
    audio.muted = not audio.muted
    if audio.currentMusic then
        audio.currentMusic:setVolume(audio.muted and 0 or audio.musicVolume)
    end
end

return audio