---@diagnostic disable: duplicate-set-field
-- Tamagotchi-like pet simulator
-- Pet = require 'modules.pet'
GS = require 'libs.hump.gamestate'
GameLoop = require 'states.gameloop'
bDebug = true  -- Enable debug mode (J/K keys and debug display)

function love.load()
    GS.registerEvents()
    GS.switch(GameLoop)
end