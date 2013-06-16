-----------------------------------------------------------------------------------------
--
-- level49.lua
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
	common.createSceneCommon(screenGroup, 200, "level49", "level50", storyboard)

	local wood = utility.addWood(750, -100, screenGroup)
	local wood2 = utility.addWood(350, -280, screenGroup)

	local conveyer1 = common.addShortConveyer(screenGroup, 300, 600, 1)
	local flowerColour = {255, 255, 0}
	local flower = common.addFlower(550, 300, 920, 500, flowerColour, screenGroup)

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