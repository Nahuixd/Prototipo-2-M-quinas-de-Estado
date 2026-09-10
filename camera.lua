local Camera = {}
Camera.__index = Camera

function Camera.new(w, h)
    return setmetatable({
        x = 0, y = 0,
        w = w, h = h,
        suavizado = 8,
        shakeDuration = 0,
        shakeIntensity = 5,
    }, Camera)
end

function Camera:attach()
    love.graphics.push()
    love.graphics.translate(-self.x + self.w / 2, -self.y + self.h / 2)

    if self.shakeDuration > 0 then
        local i = self.shakeIntensity
        love.graphics.translate(
            love.math.random(-i, i),
            love.math.random(-i, i)
        )
    end
end

function Camera:detach()
    love.graphics.pop()
end

function Camera:follow(target, dt)
    local t = math.min(1, dt * self.suavizado)
    self.x = self.x + (target.x - self.x) * t
    self.y = self.y + (target.y - self.y) * t
end

function Camera:snapTo(target)
    self.x, self.y = target.x, target.y
end

function Camera:shake(duracion, intensidad)
    self.shakeDuration = math.max(self.shakeDuration, duracion or 0.3)
    if intensidad then
        self.shakeIntensity = intensidad
    end
end

function Camera:update(dt)
    if self.shakeDuration > 0 then
        self.shakeDuration = self.shakeDuration - dt
        if self.shakeDuration < 0 then
            self.shakeDuration = 0
        end
    end
end

return Camera