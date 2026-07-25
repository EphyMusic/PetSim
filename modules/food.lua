local Object = require 'libs.classic.classic'

---@class Food
local Food = Object:extend()

function Food:new(x,y,w,h,name,value)
    self.x = x
    self.lastX = x
    self.y = y
    self.lastY = y
    self.velocityY = 0
    self.gravity = 900
    self.width = w
    self.height = h
    self.name = name
    self.value = value
    self.consumed = false
end

function Food:checkCollision(wall)
    return self.x + self.width > wall.x
    and self.x < wall.x + wall.width
    and self.y + self.height > wall.y
    and self.y < wall.y + wall.height
end

function Food:resolveCollision(walls)
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

function Food:sideCollision(wall)
    return self.lastY < wall.y + wall.height and self.lastY + self.height > wall.y
end

function Food:verticalCollision(wall)
    return self.lastX < wall.x + wall.width and self.lastX + self.width > wall.x
end

function Food:fall(dt)