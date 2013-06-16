-----------------------------------------------------------------------------------------
--
-- level21.lua
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
	common.createSceneCommon(screenGroup,300, "level21", "level20", storyboard)	

	local colour = {102, 255, 178}
	local colour2 = {102, 102, 178}
	local colour3 = {255, 255, 0}

	common.addFlower(421, 342, 920, 400, colour, screenGroup)
	common.addFlower(351, 342, 820, 400, colour2, screenGroup)
	common.addFlower(281, 342, 720, 400, colour3, screenGroup)

	utility.addWood(540, -50, screenGroup)

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