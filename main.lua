---@diagnostic disable: duplicate-set-field
---@diagnostic disable: lowercase-global
-- Tamagotchi-like pet simulator
-- Pet = require 'modules.pet'
GS = require 'libs.hump.gamestate'
GameLoop = require 'states.gameloop'
bDebug = false  -- Enable debug mode (J/K keys and debug display)
bHandheld = false

function love.load()
    GS.registerEvents()
    GS.switch(GameLoop)
end