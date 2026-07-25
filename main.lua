---@diagnostic disable: duplicate-set-field
---@diagnostic disable: lowercase-global
-- Tamagotchi-like pet simulator
-- Pet = require 'modules.pet'
GS = require 'libs.hump.gamestate'
GameLoop = require 'states.gameloop'

bDebug = true
bHandheld = false
if #arg > 0 then
    for i,v in ipairs(arg) do
        if v == "-debug" then bDebug = true end
        if v == "-handheld" then bHandheld = true end
    end
end

function love.load()

    GS.registerEvents()
    GS.switch(GameLoop)
end