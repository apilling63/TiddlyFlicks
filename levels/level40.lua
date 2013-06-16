-----------------------------------------------------------------------------------------
--
-- level40.lua
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
	common.createSceneCommon(screenGroup, 200, "level40", "level41", storyboard)
	local wasp = utility.addWasp(screenGroup, 750, 400)
	common.moveWasp(wasp, 600, 300, 850, 500)

	local wasp2 = utility.addWasp(screenGroup, 300, 300)
	common.moveWasp(wasp2, 200, 200, 400, 400)

	local wasp3 = utility.addWasp(screenGroup, 500, 200)
	common.moveWasp(wasp3, 400, 100, 600, 300)

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