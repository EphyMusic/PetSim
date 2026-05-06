local Object = require 'test_Game.libs.classic.classic'

local Pet = Object:extend()

function Pet:new()
    self.hp = 100
    self.hunger = 0
    self.hungerMax = 10
    self.x = 100
    self.y = 100
end

function Pet:draw(x,y)
    
end