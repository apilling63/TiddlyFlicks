-----------------------------------------------------------------------------------------
--
-- level51.lua
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
	common.createSceneCommon(screenGroup, 880, "level51", "level52", storyboard)
	local can = utility.addCanTargetNoTopWood(screenGroup, 465, 280, true)
	common.addCanTargetExitCover(can, 500, 580, screenGroup)

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