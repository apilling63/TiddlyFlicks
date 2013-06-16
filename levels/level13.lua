-----------------------------------------------------------------------------------------
--
-- level13.lua
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
	common.createSceneCommon(screenGroup, 880, "level13", "level22", storyboard)
	colour = {0, 153, 51}
	local leaf = common.addLeaf(450, 455, 580, colour, screenGroup)
	common.makePlatformMoveY(leaf.platform, 1, 100, 500)

	leftPillar = utility.addWood(330, 180, screenGroup)
	rightPillar = utility.addWood(630, 180, screenGroup) 

	leftPillar:toBack()
	rightPillar:toBack()
	background:toBack()
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