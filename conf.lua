function love.conf(t)
    t.identity = "mi_juego"
    t.version  = "11.4"

    t.window.title     = "Mi Maquinola Game"
    t.window.width     = 800
    t.window.height    = 600
    t.window.resizable = false
    t.window.vsync     = 1

    t.modules.physics = false
end