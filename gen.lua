local gen = {}

local tile_size = 32   -- ajustá según tu grilla

-- Redondea al múltiplo de m más cercano (útil para grillas)
function gen.roundm(n, m)
    return math.floor((n + m - 1) / m) * m
end

-- Punto aleatorio uniforme dentro de un círculo (rejection sampling)
function gen.pointInCircle(radius, snap)
    local t = 2 * math.pi * math.random()
    local u = math.random() + math.random()
    local r = (u > 1) and (2 - u) or u
    local x = radius * r * math.cos(t)
    local y = radius * r * math.sin(t)
    if snap then
        x = gen.roundm(x, tile_size)
        y = gen.roundm(y, tile_size)
    end
    return x, y
end

-- Punto aleatorio dentro de una elipse
function gen.pointInEllipse(w, h, snap)
    local t = 2 * math.pi * math.random()
    local u = math.random() + math.random()
    local r = (u > 1) and (2 - u) or u
    local x = w * r * math.cos(t) / 2
    local y = h * r * math.sin(t) / 2
    if snap then
        x = gen.roundm(x, tile_size)
        y = gen.roundm(y, tile_size)
    end
    return x, y
end

-- Distribución en espiral: lindo para monedas o enemigos
function gen.pointInSpiral(index, spacing, angleStep)
    spacing   = spacing   or 48
    angleStep = angleStep or 2.399963  -- ángulo dorado → distribución tipo girasol
    local r = spacing * math.sqrt(index)
    local a = angleStep * index
    return r * math.cos(a), r * math.sin(a)
end

-- Genera N monedas sin superponerse (distancia mínima)
-- usando los helpers de arriba
function gen.scatter(count, opts)
    opts = opts or {}
    local radio      = opts.radius      or 500
    local minDist    = opts.minDist     or 40
    local maxIntentos = opts.maxIntentos or 30

    local puntos = {}

    for i = 1, count do
        local colocado = false
        for _ = 1, maxIntentos do
            local x, y = gen.pointInEllipse(radio * 2, radio * 2)
            local ok = true
            for _, p in ipairs(puntos) do
                local dx, dy = p.x - x, p.y - y
                if dx * dx + dy * dy < minDist * minDist then
                    ok = false
                    break
                end
            end
            if ok then
                puntos[#puntos + 1] = { x = x, y = y }
                colocado = true
                break
            end
        end
        -- Si falla mucho, lo tiramos en espiral para no colgar el juego
        if not colocado then
            local x, y = gen.pointInSpiral(i, minDist * 1.5)
            puntos[#puntos + 1] = { x = x, y = y }
        end
    end

    return puntos
end

return gen