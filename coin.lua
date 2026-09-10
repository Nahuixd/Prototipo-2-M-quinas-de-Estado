local Coin = {}
Coin.__index = Coin

function Coin.new(x, y, image, scale)
    local self = setmetatable({}, Coin)
    self.x, self.y  = x, y
    self.size       = 10                       -- radio de colisión base
    self.image      = image
    self.scale      = scale or 1               -- 🎨 escala visual
    self.t          = love.math.random() * math.pi * 2
    self.collected  = false
    return self
end

function Coin:update(dt)
    self.t = self.t + dt * 3
end

function Coin:draw(showDebug)
    local w, h = self.image:getWidth(), self.image:getHeight()
    local y = self.y + math.sin(self.t) * 3    -- flotación
    love.graphics.draw(self.image, self.x, y, 0,
        self.scale, self.scale,                -- 🎨 escala
        w / 2, h / 2)
    if showDebug then
        love.graphics.circle("line", self.x, self.y, self.size)
    end
end

return Coin