-----------------------------------------------------------------------------------------
--
-- level3.lua
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
	common.createSceneCommon(screenGroup, 800, "level3", "level26", storyboard, true)

	local barrier = utility.addWood(250, 450, screenGroup)
	barrier:toBack()
	background:toBack()
	common.setHelpText("TIP: Flick down from the bottom of", "the face for a steep trajectory")

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