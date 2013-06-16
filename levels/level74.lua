-----------------------------------------------------------------------------------------
--
-- level74.lua
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
	common.createSceneCommon(screenGroup, 300, "level74", "level35", storyboard)

	local wood = utility.addWood(300, -370, screenGroup)
	local wood = utility.addWood(750, 370, screenGroup)

	local conveyer1 = common.addShortConveyer(screenGroup, 350, 500, 1)
	local conveyer2 = common.addShortConveyer(screenGroup, 600, 250, 1)

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