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
    self.currentPet = 1
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

-- Create walls around the play area
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

-- Feed all active pets by satiation amount
function GameLoop:feedPets(s)
    for _,pet in ipairs(self.pets) do
        pet:feed(s)
    end
end

-- Create UI buttons
function GameLoop:buildUI()
    table.insert(self.ui,
    Button(50,
    love.graphics.getHeight()/2 + 10,60,30,
    "Feed",
    function()
        self:feedPets(1)
    end)
    )
end

function GameLoop:update(dt)
    for _, pet in ipairs(self.pets) do
        pet:update(dt)
        pet:resolveCollision(self.walls)
    end
end

-- Controls: F=feed, J=easier, K=harder, N=new pet, Q=quit
function GameLoop:keyreleased(key)
    if key == "q" then love.event.quit() end

    local pet = self.pets[self.currentPet]  -- pet to control
    if pet and not pet.dead then
        if key == "f" and (bDebug or bHandheld) then pet:feed(1) end
        if key == "j"  and bDebug then
            pet.hungerMulti = math.max(0, (pet.hungerMulti or 0) - 1)
            pet.damageMulti = math.max(0, (pet.damageMulti or 0) - 1)
        elseif key == "k"  and bDebug then
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

-- Handle mouse clicks on UI elements
function GameLoop:mousepressed(x,y,mkey)
    for _,elem in ipairs(self.ui) do
        if mkey == 1 then
            elem:handleClick(x,y)()
        end
    end
end

-- Update UI hover states on mouse movement
function GameLoop:mousemoved(x,y)
    for _,elem in ipairs(self.ui) do
        elem:handleHover(x,y)
    end
end

function GameLoop:draw()
    -- -- Draw all pets
    -- for _, pet in ipairs(self.pets) do
    --     if not pet.dead then
    --         pet:draw()
    --     end
    -- end

    local pet = self.pets[1]
    pet:draw()
    if pet and not pet.dead then
        for _,wall in ipairs(self.walls) do
            wall:draw()
        end

        for _,elem in ipairs(self.ui) do
            if elem and not elem.disabled then elem:draw() end
        end

        love.graphics.print("Name: "..pet.name)
        love.graphics.print("HP: " .. fmt2(pet.hp), 10, 30)
        love.graphics.print(
            "Hunger: " .. fmt2(pet.hunger) .. "/" .. fmt2(pet.hungerMax),
            10, 50
        )
        love.graphics.print("Happiness: " .. fmt2(pet.cheer),10,70)
    elseif pet and pet.dead then
        love.graphics.print('Your pet has died.\nPress "n" to hatch a new pet.',love.graphics.getWidth()/2,love.graphics.getHeight()/2)
    end

    if bDebug then
        love.graphics.printf("Debug | v1", love.graphics.getWidth() - 60, 10, 50,"right")
        love.graphics.printf("J = -Hunger -Damage | K = +Hunger +Damage", love.graphics.getWidth() - 156, 35, 145,"right")
        love.graphics.printf("Hunger/Damage Rate:\n" .. self.pets[1].hungerMulti,love.graphics.getWidth() -160,75,150,"right")
    end
end

return GameLoop