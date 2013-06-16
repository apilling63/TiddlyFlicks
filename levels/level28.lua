-----------------------------------------------------------------------------------------
--
-- level28.lua
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
	common.createSceneCommon(screenGroup, 680, "level28", "level34", storyboard)
	can = utility.addCanTarget(screenGroup, 365, 280)
	can.name = "can"
end

-- add all the event listening
function scene:enterScene(event)
	if can.x ~= 406 then
		can.x = 406
	end
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