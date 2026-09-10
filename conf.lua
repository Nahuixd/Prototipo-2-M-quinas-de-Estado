function love.conf(t)
    t.identity = "maquinas_de_estado_prog2"     -- 🆕 carpeta de guardado (sin espacios)
    t.version  = "11.4"

    t.window.title     = "Maquinas De Estado Programacion 2"   -- 🆕 título de la ventana
    t.window.width     = 800
    t.window.height    = 600
    t.window.resizable = false
    t.window.vsync     = 1

    t.modules.physics = false
end