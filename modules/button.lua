local Object = require 'libs.classic.classic'

---@class Button
local Button = Object:extend()

-- Create a clickable button with text and callback function
function Button:new(x,y,w,h,text,func)
    self.x = x
    self.y = y
    self.width = w
    self.height = h
    self.text = text
    self.action = func
    self.hovered = false
    self.colorIn = {love.math.colorFromBytes(50,50,50)}      -- Infill color
    self.colorOut = {love.math.colorFromBytes(200,200,200)}  -- Outline color
end

-- Check if click is inside button bounds, return action or empty function
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

-- Update hover state based on mouse position
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
        -- Fill (swap colors when hovered)
        if not self.hovered then
            love.graphics.setColor(unpack(self.colorIn))
        else
            love.graphics.setColor(unpack(self.colorOut))
        end
        love.graphics.rectangle("fill",self.x,self.y,self.width,self.height)

        -- Outline (swap colors when hovered)
        if not self.hovered then
            love.graphics.setColor(unpack(self.colorOut))
        else
            love.graphics.setColor(unpack(self.colorIn))
        end
        love.graphics.rectangle("line",self.x,self.y,self.width,self.height)

        -- Text (centered vertically and horizontally)
        if not self.hovered then
            love.graphics.setColor(1,1,1)
        else
            love.graphics.setColor(0,0,0)
        end
        
        local font = love.graphics.getFont()
        local fontHeight = font and font:getHeight() or 0
        local textY = self.y + (self.height - fontHeight) / 2
        love.graphics.printf(self.text, self.x, textY, self.width, "center")
    love.graphics.pop()
end

return Button