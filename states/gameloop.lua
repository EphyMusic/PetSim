local GameLoop = {}
local Pet = require "modules.pet"
local Wall = require "modules.bounds"
local Button = require "modules.button"

-- Round to 2 decimal places
local function round2(n)
    n = tonumber(n) or 0
    if n >= 0 then
        return math.floor(n * 100 + 0.5) / 100
    end
    return math.ceil(n * 100 - 0.5) / 100
end

-- Format number, removing trailing zeros
local function fmt2(n)
    n = round2(n)
    local s = string.format('%.2f', n)
    s = s:gsub('0+$', ''):gsub('%.$', '')
    return s
end

function GameLoop:enter()
    self.pets = {}  -- Active pets
    self.walls = {}
    self.deadPets = {}
    self:addPet(Pet())  -- Start with one pet
    self:buildWalls(100,100,100)
    self.ui = {}
    self:buildUI()
end

-- Add a pet to the active pets list
function GameLoop:addPet(pet)
    table.insert(self.pets, pet)
end

function GameLoop:buildWalls(r,g,b)
    table.insert(self.walls,Wall(0,0,10,love.graphics.getHeight(),r,g,b)) --left wall
    table.insert(self.walls,Wall(love.graphics.getWidth()-10,0,10,love.graphics.getHeight(),r,g,b)) --right wall
    table.insert(self.walls,Wall(0,0,love.graphics.getWidth(),10,r,g,b)) --top wall
    table.insert(self.walls,Wall(0,love.graphics.getHeight()/2,love.graphics.getWidth(),love.graphics.getHeight()/2,r,g,b)) --bottom wall
end

-- Remove a pet from the active pets list
function GameLoop:removePet(pet)
    for i, p in ipairs(self.pets) do
        if p == pet then
            table.remove(self.pets, i)
            return true
        end
    end
    return false
end

function GameLoop:buildUI()
    feed = Button() --start here!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
end

function GameLoop:update(dt)
    for _, pet in ipairs(self.pets) do
        pet:update(dt)
    end
end

-- Controls: F=feed, J=easier, K=harder, N=new pet, Q=quit
function GameLoop:keyreleased(key)
    if key == "q" then love.event.quit() end
    
    local pet = self.pets[1]  -- For now, control the first pet
    if pet and not pet.dead then
        if key == "f" then pet:feed(1)
        elseif key == "j" then
            pet.hungerMulti = math.max(0, (pet.hungerMulti or 0) - 1)
            pet.damageMulti = math.max(0, (pet.damageMulti or 0) - 1)
        elseif key == "k" then
            pet.hungerMulti = math.max(0, (pet.hungerMulti or 0) + 1)
            pet.damageMulti = math.max(0, (pet.damageMulti or 0) + 1)
        end
    elseif pet and pet.dead then
        if key == "n" then
            self:removePet(pet)
            table.insert(self.deadPets, pet)
            self:addPet(Pet())
        end
    end
end

function GameLoop:mousepressed(key)
    
end

function GameLoop:draw()
    -- Draw all pets
    for _, pet in ipairs(self.pets) do
        pet:draw()
    end
    
    -- Display stats for first pet
    local pet = self.pets[1]
    if pet and not pet.dead then
        love.graphics.print("HP: " .. fmt2(pet.hp), 10, 10)
        love.graphics.print(
            "Hunger: " .. fmt2(pet.hunger) .. "/" .. fmt2(pet.hungerMax),
            10,
            30
        )
    elseif pet and pet.dead then
        love.graphics.print('Your pet has died.\nPress "n" to hatch a new pet.',love.graphics.getWidth()/2,love.graphics.getHeight()/2)
    end

    for _,wall in ipairs(self.walls) do
        wall:draw()
    end
end

return GameLoop