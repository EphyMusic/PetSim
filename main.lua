---@diagnostic disable: duplicate-set-field
--Tamagotchi-like
Pet = require 'modules.pet'
GS = require 'libs.hump.gamestate'
GameLoop = require 'states.gameloop'

function love.load()
    GS.registerEvents()
    GS.switch(GameLoop)
end