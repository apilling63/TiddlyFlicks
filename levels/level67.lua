-----------------------------------------------------------------------------------------
--
-- level67.lua
--
-----------------------------------------------------------------------------------------

-- allow this lua file to be used with storyboards
local storyboard = require "storyboard"
local scene = storyboard.newScene()
local common = require ("common")

-- what to do when the screen loads
function scene:createScene(event)
	screenGroup = self.view
	common.createSceneCommon(screenGroup, 100, "level67", "level24", storyboard)
	common.addLeaf(750, 500, 580, nil, screenGroup)
	common.addLeaf(600, 400, 570, nil, screenGroup)
	common.addLeaf(350, 300, 560, nil, screenGroup)
	common.addLeaf(200, 200, 550, nil, screenGroup)

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