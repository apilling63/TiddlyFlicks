-----------------------------------------------------------------------------------------
--
-- level9.lua
--
-----------------------------------------------------------------------------------------

-- allow this lua file to be used with storyboards
local storyboard = require "storyboard"
local scene = storyboard.newScene()
local common = require ("common")

local physics = require "physics"  
physics.start()  
physics.setGravity(0, 9.81)
physics.setScale(80)  -- 80 pixels per meter  

-- what to do when the screen loads
function scene:createScene(event)
	local screenGroup = self.view
	common.createSceneCommon(screenGroup, 600, "level9", "level10", storyboard)

	wink2 = utility.loadImage("orangeWink.png")  
	wink2:translate(80, 600) 
	common.addWink(wink2, "orange", 880, 960, screenGroup, wink, "no")

	wink3 = utility.loadImage("orangeWink.png")  
	wink3:translate(110, 600) 
	common.addWink(wink3, "orange", 880, 960, screenGroup, wink2, "yes")

	wink:toFront()
	wink2:toFront()
	wink3:toFront()
	potFront:toFront()
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