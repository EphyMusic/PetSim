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
    self.hovered = false
    self.colorIn = {love.math.colorFromBytes(50,50,50)}
    self.colorOut = {love.math.colorFromBytes(200,200,200)}
end

function Button:handleClick(clickX,clickY)
    local function nothing() end
    if clickX >= self.x and
    clickY >= self.y and
    clickX <= self.x + self.width and
    clickY <= self.y + self.height then
        return self.action
    else
        return nothing
    end
end

function Button:handleHover(mouseX,mouseY)
    if mouseX >= self.x and
    mouseY >= self.y and
    mouseX <= self.x + self.width and
    mouseY <= self.y + self.height then
        self.hovered = true
    else
        self.hovered = false
    end
end

function Button:draw()
    love.graphics.push()
        --Infill
        if not self.hovered then
            love.graphics.setColor(unpack(self.colorIn))
        else
            love.graphics.setColor(unpack(self.colorOut))
        end
        love.graphics.rectangle("fill",self.x,self.y,self.width,self.height)

        --Outline
        if not self.hovered then
            love.graphics.setColor(unpack(self.colorOut))
        else
            love.graphics.setColor(unpack(self.colorIn))
        end
        love.graphics.rectangle("line",self.x,self.y,self.width,self.height)

        --Text
        love.graphics.setColor(1,1,1)
        local font = love.graphics.getFont()
        local fontHeight = font and font:getHeight() or 0
        local textY = self.y + (self.height - fontHeight) / 2
        love.graphics.printf(self.text, self.x, textY, self.width, "center")
    love.graphics.pop()
end

return Button