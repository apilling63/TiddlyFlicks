-----------------------------------------------------------------------------------------
--
-- level53.lua
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
	common.createSceneCommon(screenGroup, 880, "level54", "completedScreen", storyboard)
	local colour = {0,0,0}
	common.addHoop(300, 420, 580, colour, screenGroup)
	common.addHoop(600, 420, 570, colour, screenGroup)

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