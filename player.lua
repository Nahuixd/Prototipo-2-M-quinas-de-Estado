local Player = {}
Player.__index = Player

-- keys:  { up="w", down="s", left="a", right="d" }
-- scale: 1 = tamaño original, 0.5 = mitad, 2 = doble
function Player.new(x, y, image, keys, scale)
    local self = setmetatable({}, Player)
    self.x, self.y   = x, y
    self.size        = 20                       -- radio de colisión base
    self.speed       = 260
    self.image       = image
    self.keys        = keys
    self.scale       = scale or 1               -- 🎨 escala visual
    self.score       = 0
    return self
end

function Player:update(dt)
    local dx, dy = 0, 0
    local k = self.keys
    if love.keyboard.isDown(k.left)  then dx = dx - 1 end
    if love.keyboard.isDown(k.right) then dx = dx + 1 end
    if love.keyboard.isDown(k.up)    then dy = dy - 1 end
    if love.keyboard.isDown(k.down)  then dy = dy + 1 end

    if dx ~= 0 and dy ~= 0 then
        local inv = 1 / math.sqrt(2)
        dx, dy = dx * inv, dy * inv
    end

    self.x = self.x + dx * self.speed * dt
    self.y = self.y + dy * self.speed * dt
end

function Player:collidesWith(other)
    local dx, dy = self.x - other.x, self.y - other.y
    local r = self.size + other.size
    return dx * dx + dy * dy <= r * r
end

function Player:draw(showDebug)
    local w, h = self.image:getWidth(), self.image:getHeight()
    love.graphics.draw(self.image, self.x, self.y, 0,
        self.scale, self.scale,           -- 🎨 escala X, escala Y
        w / 2, h / 2)                     -- origen al centro
    if showDebug then
        love.graphics.circle("line", self.x, self.y, self.size)
    end
end

return Player