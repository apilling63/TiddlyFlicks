-----------------------------------------------------------------------------------------
--
-- level35.lua
--
-----------------------------------------------------------------------------------------

-- allow this lua file to be used with storyboards
local storyboard = require "storyboard"
local scene = storyboard.newScene()
local common = require ("common")
local utility = require ("utility")

-- what to do when the screen loads
function scene:createScene(event)
	local screenGroup = self.view
	common.createSceneCommon(screenGroup, 730, "level35", "level36", storyboard)
	local can = utility.addCanTargetNoTopWood(screenGroup, 615, 280, true)
	common.addCanTargetExitCover(can, 500, 580, screenGroup)
	local can2 = utility.addCanTargetNoTopWood(screenGroup, 315, 280, true)
	common.addCanTargetExitCover(can2, 500, 570, screenGroup)
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