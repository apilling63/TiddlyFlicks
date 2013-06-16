-----------------------------------------------------------------------------------------
--
-- level8.lua
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
	common.createSceneCommon(screenGroup, 300, "level8", "level21", storyboard)

	utility.addWood(550, -150, screenGroup)

	local colour = {255, 255, 0}
	common.addFlower(220, 350, 920, 400, colour, screenGroup)
	common.setHelpText("TIP: The centre of flowers have", "special powers")
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