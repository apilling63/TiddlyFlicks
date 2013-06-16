-----------------------------------------------------------------------------------------
--
-- level36.lua
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
	common.createSceneCommon(screenGroup, 880, "level36", "level37", storyboard)
	local wasp = utility.addWasp(screenGroup, 300, 500)
	common.moveWasp(wasp, 200, 400, 400, 600)

	local wasp2 = utility.addWasp(screenGroup, 600, 300)
	common.moveWasp(wasp2, 500, 200, 700, 400)
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