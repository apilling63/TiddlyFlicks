-----------------------------------------------------------------------------------------
--
-- level58.lua
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
	common.createSceneCommon(screenGroup, 200, "level58", "completedScreen", storyboard)
	local colour = {0,0,0}
	common.addCloud(600, 420, 580, colour, screenGroup)
	common.addHoop(400, 320, 570, colour, screenGroup)
	common.addCloud(200, 420, 580, colour, screenGroup)

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