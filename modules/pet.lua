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
    self.name = names[love.math.random() * #names]
    self.dead = false
    self.hp = 100
    self.hunger = 0
    self.hungerMax = 10
    self.cheer = 0
    self.cheerMax = 100
    self.cheerDrainRate = 0.1
    self.x = 250
    self.lastX = self.x
    self.y = 200
    self.lastY = self.y
    self.width = 25
    self.height = 50
    self.velocityX = 0
    self.velocityY = 200
    self.targetX = nil
    self.maxSpeed = 100
    self.speedMulti = 1
    self.moveState = "idle"
    self.moveBounds = {
        left = 10,
        right = love.graphics.getWidth() - 10,
    }
    self.timer = Timer.new()
    self.hungerRate = 0.7
    self.hungerMulti = 1
    self.hungerTick = self.timer:every(2, function()  -- Hunger increases every 2s
        self:starve()
    end)
    self.damageRate = 1
    self.damageMulti = 1
    self.damageTick = self.timer:every(1, function()  -- Damage check every 1s
        self:takeDamage()
    end)
    self.cheerTick = self.timer:every(3, function()
        self:loseCheer()
    end)
    self.color = {love.math.colorFromBytes(love.math.random(0,255), love.math.random(0,255), love.math.random(0,255))}  -- Random color
    self:scheduleNextMove()
end

-- Random hunger rate between min and max
function Pet:rollHungerRate()
    local minRate = 0.05
    local maxRate = 0.3 * (self.hungerMulti or 1)
    return round2(minRate + (maxRate - minRate) * love.math.random())
end

function Pet:rollCheerRate()
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
        self.hungerRate = self:rollHungerRate()
    end
end

function Pet:loseCheer()
    if self.cheer > 0 then
        self.cheer = round2(math.max(0, self.cheer - self.cheerDrainRate))
        self.cheerDrainRate = self:rollCheerRate()
    end
end

-- Current speed scales with HP and hunger
function Pet:getMaxSpeed()
    local hpFactor = math.max(0, math.min(1, self.hp / 100))
    local hungerFactor = math.max(0.75, 1 - 0.25 * (self.hunger / self.hungerMax))
    return self.maxSpeed * self.speedMulti * hpFactor * hungerFactor
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

-- Pause, then pick a new horizontal destination
function Pet:scheduleNextMove()
    if self.dead then return end

    self.moveState = "idle"
    self.velocityX = 0
    self.targetX = nil

    local idleTime = love.math.random(0.5,2.5)
    self.timer:after(idleTime, function()
        if self.dead then return end
        self:startRandomMove()
    end)
end

function Pet:checkCollision(wall)
    return self.x + self.width > wall.x
    and self.x < wall.x + wall.width
    and self.y + self.height > wall.y
    and self.y < wall.y + wall.height
end

function Pet:resolveCollision(walls)
    for _,wall in ipairs(walls) do
        if self:checkCollision(wall) then
            if self:sideCollision(wall) then
                if self.x + self.width/2 < wall.x + wall.width/2 then
                    local pushback = self.x + self.width - wall.x   -- push left
                    self.x = self.x - pushback
                else
                    local pushback = wall.x + wall.width - self.x   -- push right
                    self.x = self.x + pushback
                end
            elseif self:verticalCollision(wall) then
                if self.y + self.height/2 < wall.y + wall.height/2 then
                    local pushback = self.y + self.height - wall.y  -- push up
                    self.y = self.y - pushback
                else
                    local pushback = wall.y + wall.height - self.y  -- push down
                    self.y = self.y + pushback
                end
            end
        end
    end
end

function Pet:sideCollision(wall)
    return self.lastY < wall.y + wall.height and self.lastY + self.height > wall.y
end

function Pet:verticalCollision(wall)
    return self.lastX < wall.x + wall.width and self.lastX + self.width > wall.x
end

-- Choose a non-trivial destination inside the movement bounds
function Pet:startRandomMove()
    local minX = self.moveBounds.left
    local maxX = self.moveBounds.right - self.width
    local minDistance = 25
    local targetX = self.x
    local attempts = 0

    while math.abs(targetX - self.x) < minDistance and attempts < 10 do
        targetX = love.math.random(minX, maxX)
        attempts = attempts + 1
    end

    if math.abs(targetX - self.x) < minDistance then
        self:scheduleNextMove()
        return
    end

    self.targetX = targetX
    self.moveState = "moving"
end

function Pet:update(dt)
    self.lastX = self.x
    self.lastY = self.y
    self.y = self.y + self.velocityY * dt
    if self.dead then return end
    self.timer:update(dt)

    if self.moveState == "moving" and self.targetX then
        local direction = 0
        if self.targetX > self.x then
            direction = 1
        elseif self.targetX < self.x then
            direction = -1
        end

        self.velocityX = direction * self:getMaxSpeed()
        self.x = self.x + self.velocityX * dt

        if direction > 0 and self.x >= self.targetX then
            self.x = self.targetX
            self:scheduleNextMove()
        elseif direction < 0 and self.x <= self.targetX then
            self.x = self.targetX
            self:scheduleNextMove()
        end
    end
end

function Pet:die()
    self.dead = true
    self.timer:clear()
end

function Pet:draw(x,y)
    love.graphics.push()
        love.graphics.setColor(unpack(self.color))
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    love.graphics.pop()
end

local names = {"Bob","George","Penny","Amy","Darla","Conroy","Little Biddy","Unnamed"}

return Pet