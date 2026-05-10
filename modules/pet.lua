local Object = require 'libs.classic.classic'
local Timer = require 'libs.hump.timer'
local Pet = Object:extend()

-- Round to 2 decimal places
local function round2(n)
    n = tonumber(n) or 0
    if n >= 0 then
        return math.floor(n * 100 + 0.5) / 100
    end
    return math.ceil(n * 100 - 0.5) / 100
end

-- Initialize pet with default stats
function Pet:new()
    self.dead = false
    self.hp = 100
    self.hunger = 0
    self.hungerMax = 10
    self.x = 250
    self.y = 200
    self.timer = Timer.new()
    self.hungerRate = round2(0.7)
    self.hungerMulti = 1
    self.hungerTick = self.timer:every(2, function()  -- Hunger increases every 2s
        self:starve()
    end)
    self.damageRate = 1
    self.damageMulti = 1
    self.damageTick = self.timer:every(1, function()  -- Damage check every 1s
        self:takeDamage()
    end)
    self.color = {love.math.colorFromBytes(love.math.random(0,255), love.math.random(0,255), love.math.random(0,255))}  -- Random color
end

-- Random hunger rate between min and max
function Pet:rollRate()
    local minRate = 0.05
    local maxRate = 0.3 * (self.hungerMulti or 1)
    return round2(minRate + (maxRate - minRate) * love.math.random())
end

-- Reduce hunger by satiation amount
function Pet:feed(satiation)
    satiation = tonumber(satiation) or 0
    if self.hunger > 0 then
        self.hunger = round2(math.max(0, self.hunger - satiation))
    end
end

-- Increase hunger over time
function Pet:starve()
    if self.hunger < self.hungerMax then
        self.hunger = round2(math.min(self.hungerMax, self.hunger + self.hungerRate))
        self.hungerRate = self:rollRate()
    end
end

-- Damage when hungry, heal when fed
function Pet:takeDamage()
    if self.hunger >= self.hungerMax then  -- Starving: take damage
        self.hp = round2(math.max(0, self.hp - self.damageRate * self.damageMulti))
        if self.hp <= 0 then self:die() end
    elseif self.hunger <= 5 then  -- Well fed: regenerate
        self.hp = round2(math.min(100, self.hp + self.damageRate / 3))
    end
end

function Pet:update(dt)
    if self.dead then return end
    self.timer:update(dt)
end

function Pet:die()
    self.dead = true
    self.timer:clear()
end

function Pet:draw(x,y)
    love.graphics.push()
        love.graphics.setColor(unpack(self.color))
        love.graphics.rectangle("fill", self.x, self.y, 50, 50)
    love.graphics.pop()
end

return Pet