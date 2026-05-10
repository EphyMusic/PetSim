local GameLoop = {}
local Pet = require "modules.pet"

local function round2(n)
    n = tonumber(n) or 0
    if n >= 0 then
        return math.floor(n * 100 + 0.5) / 100
    end
    return math.ceil(n * 100 - 0.5) / 100
end

local function fmt2(n)
    n = round2(n)
    local s = string.format('%.2f', n)
    s = s:gsub('0+$', ''):gsub('%.$', '')
    return s
end

function GameLoop:enter()
    self.pet = Pet()
    self.deadPets = {}
end

function GameLoop:update(dt)
    self.pet:update(dt)
end

function GameLoop:keyreleased(key)
    if key == "q" then love.event.quit() end
    if not self.pet.dead then
        if key == "f" then self.pet:feed(1)
        elseif key == "j" then
            self.pet.hungerMulti = math.max(0, (self.pet.hungerMulti or 0) - 1)
            self.pet.damageMulti = math.max(0, (self.pet.damageMulti or 0) - 1)
        elseif key == "k" then
            self.pet.hungerMulti = math.max(0, (self.pet.hungerMulti or 0) + 1)
            self.pet.damageMulti = math.max(0, (self.pet.damageMulti or 0) + 1)
        end
    else
        if key == "n" then
            table.insert(self.deadPets, self.pet)
            self.pet = Pet()
        end
    end
end

function GameLoop:draw()
    if not self.pet.dead then
        self.pet:draw()

        love.graphics.print("HP: " .. fmt2(self.pet.hp), 10, 10)
        love.graphics.print(
            "Hunger: " .. fmt2(self.pet.hunger) .. "/" .. fmt2(self.pet.hungerMax),
            10,
            30
        )
    else
        love.graphics.print('Your pet has died.\nPress "n" to hatch a new pet.',love.graphics.getWidth()/2,love.graphics.getHeight()/2)
    end
end

return GameLoop