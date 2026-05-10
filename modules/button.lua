local Object = require 'libs.classic.classic'

---@class Button
local Button = Object:extend()

function Button:new(x,y,w,h,text,func)
    self.x = x
    self.y = y
    self.width = w
    self.height = h
    self.text = text
    self.action = func
end

function Button:handleClick(clickX,clickY)
    if clickX >= self.x and
    clickY >= self.y and
    clickX <= self.x + self.width and
    clickY <= self.y + self.height then
        return self.action
    end
end