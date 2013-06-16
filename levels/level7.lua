-----------------------------------------------------------------------------------------
--
-- level7.lua
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
	common.createSceneCommon(screenGroup, 500, "level7", "level11", storyboard)

	colour2 = {0, 153, 51}
	common.addLeaf(600, 322, 580, colour2, screenGroup)

	colour1 = {0, 120, 0}
	common.addLeaf(400, 422, 570, colour1, screenGroup)

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