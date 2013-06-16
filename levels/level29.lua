-----------------------------------------------------------------------------------------
--
-- level29.lua
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
	common.createSceneCommon(screenGroup, 500, "level29", "level6", storyboard)

	local leaf = common.addLeaf(595, 272, 580, {0, 153, 51}, screenGroup)

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