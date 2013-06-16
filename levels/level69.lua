-----------------------------------------------------------------------------------------
--
-- level69.lua
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
	common.createSceneCommon(screenGroup, 100, "level69", "level24", storyboard)
	common.addCloud(650, 400, 580, nil, screenGroup)
	common.addCloud(200, 400, 570, nil, screenGroup)
	utility.addWood(400, 300, screenGroup)
	utility.addWood(400, -600, screenGroup)

	local wasp = utility.addWasp(screenGroup, 350, 200)
	common.moveWasp(wasp, 200, 100, 650, 500)

	common.addShortConveyer(screenGroup, 385, 280, 1)
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