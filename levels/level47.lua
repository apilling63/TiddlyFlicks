-----------------------------------------------------------------------------------------
--
-- level47.lua
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
	common.createSceneCommon(screenGroup, 450, "level47", "level48", storyboard)

	local wood = utility.addWood(450, 420, screenGroup)

	local conveyer1 = common.addLongConveyer(screenGroup, 500, 400, 1)
	local conveyer2 = common.addLongConveyer(screenGroup, 560, 300, 1)

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