-----------------------------------------------------------------------------------------
--
-- level2.lua
--
-----------------------------------------------------------------------------------------

-- allow this lua file to be used with storyboards
local storyboard = require "storyboard"
local scene = storyboard.newScene()
local common = require ("common")  

local function addStar(xLocation, yLocation, screenGroup)
	local star = display.newImage("blueStar.png")
	star:translate(xLocation, yLocation)
	screenGroup:insert(star)
end

-- what to do when the screen loads
function scene:createScene(event)
	local screenGroup = self.view
	screenGroup.isMoon = true
	common.createSceneCommon(screenGroup, 880, "level2", "level3", storyboard)
	physics.setGravity(0, 5)
	addStar(100, 300, screenGroup)
	addStar(300, 500, screenGroup)
	addStar(700, 50, screenGroup)
	addStar(600, 550, screenGroup)
	addStar(480, 350, screenGroup)

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