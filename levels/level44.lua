-----------------------------------------------------------------------------------------
--
-- level44.lua
--
-----------------------------------------------------------------------------------------

-- allow this lua file to be used with storyboards
local storyboard = require "storyboard"
local scene = storyboard.newScene()
local common = require ("common")
local utility = require ("utility")

-- what to do when the screen loads
function scene:createScene(event)
	screenGroup = self.view
	common.createSceneCommon(screenGroup, 300, "level44", "level45", storyboard)
	colour = {255, 255, 255}
	local cloud = common.addCloud(450, 420, 580, colour, screenGroup) 
	local wasp = utility.addWasp(screenGroup , 450, 420)
	common.moveWasp(wasp, 300, 200, 600, 600)
end

-- add all the event listening
function scene:enterScene(event)
	common.enterSceneCommon()
end

function scene:exitScene(event)
	common.exitSceneCommon()
end

function scene:destroyScene(event)
end

scene:addEventListener("createScene", scene)
scene:addEventListener("enterScene", scene)
scene:addEventListener("exitScene", scene)
scene:addEventListener("destroyScene", scene)

return scene