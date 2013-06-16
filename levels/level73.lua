-----------------------------------------------------------------------------------------
--
-- level73.lua
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
	common.createSceneCommon(screenGroup, 200, "level73", "level21", storyboard)

	utility.addWood(500, -200, screenGroup)
	common.addCloud(650, 500, 580, nil, screenGroup)

	local colour = {255, 255, 0}
	common.addFlower(325, 350, 720, 400, colour, screenGroup)
	local wasp = utility.addWasp(screenGroup, 700, 400)
	common.moveWasp(wasp, 650, 400, 850, 600)
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