-----------------------------------------------------------------------------------------
--
-- level32.lua
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
	common.createSceneCommon(screenGroup, 400, "level32", "level7", storyboard)
	local leaf = common.addLeaf(595, 422, 580, {0, 153, 51}, screenGroup)

	common.makePlatformMoveX(staticPlatform, 3, 500, 800)

	wink:toFront()
	potFront:toFront()
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