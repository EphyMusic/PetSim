--v2
local Object = require 'libs.classic.classic'

---@class Wall
local Wall = Object:extend()

-- Create a colored rectangular boundary
function Wall:new(x,y,w,h,r,g,b)
    self.x = x
    self.y = y
    self.width = w
    self.height = h
    self.color = {love.math.colorFromBytes(r,g,b)}
end

function Wall:draw()
    love.graphics.push()
        love.graphics.setColor(unpack(self.color))
        love.graphics.rectangle("fill",self.x,self.y,self.width,self.height)
        love.graphics.setColor(1,1,1)  -- Reset to white
    love.graphics.pop()
end

return Wall