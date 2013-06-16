-----------------------------------------------------------------------------------------
--
-- level10.lua
--
-----------------------------------------------------------------------------------------

-- allow this lua file to be used with storyboards
local storyboard = require "storyboard"
local scene = storyboard.newScene()
local common = require ("common")

-- what to do when the screen loads
function scene:createScene(event)
	local screenGroup = self.view
	common.createSceneCommon(screenGroup, 720, "level10", "level11", storyboard)

	wink2 = utility.loadImage("blueWink.png")  
	wink2:translate(80, 600) 
	common.addWink(wink2, "blue", 800, 875, screenGroup, wink, "no")

	wink3 = utility.loadImage("redWink.png")  
	wink3:translate(110, 600)    
	common.addWink(wink3, "red", 720, 795, screenGroup, wink2, "yes")

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