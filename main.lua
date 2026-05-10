---@diagnostic disable: duplicate-set-field
-- Tamagotchi-like pet simulator
-- Pet = require 'modules.pet'
GS = require 'libs.hump.gamestate'
GameLoop = require 'states.gameloop'
bDebug = true

function love.load()
    GS.registerEvents()
    GS.switch(GameLoop)
end