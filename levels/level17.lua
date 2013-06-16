-----------------------------------------------------------------------------------------
--
-- level17.lua
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
	common.createSceneCommon(screenGroup, 500, "level17", "level16", storyboard)

	colour = {0, 153, 51}
	local leaf = common.addLeaf(650, 422, 580, colour, screenGroup)

	common.makePlatformMoveY(leaf.platform, 1, 400, 625)

	colour2 = {102, 255, 178}
	local flower = common.addFlower(650, 344, 850, 580, colour2, screenGroup)
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