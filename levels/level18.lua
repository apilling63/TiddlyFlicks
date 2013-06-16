-----------------------------------------------------------------------------------------
--
-- level18.lua
--
-----------------------------------------------------------------------------------------

-- allow this lua file to be used with storyboards
local storyboard = require "storyboard"
local scene = storyboard.newScene()
local common = require ("common")
local utility = require ("utility")
local platformNum = 1

local function addPlatform(colour1, colour2, colour3, x, y, screenGroup)
	exitY = 590 - (10 * platformNum)
	platformNum = platformNum + 1
	local exitCover = display.newRect(880, exitY, 80, 10) 
	utility.addNewStaticObject(exitCover, colour1, colour2, colour3, screenGroup) 
	local staticPlatformBottom = display.newRect(x, y, 100, 5) 
	utility.addNewStaticObject(staticPlatformBottom, 0,0,0, screenGroup) 
	local staticPlatform = display.newRect(x, y - 5, 100, 5) 
	common.addNewPlatformWithRemoveObject(staticPlatform, colour1, colour2, colour3, screenGroup, exitCover) end

-- what to do when the screen loads
function scene:createScene(event)
	screenGroup = self.view
	common.createSceneCommon(screenGroup, 500, "level18", "level19", storyboard)
	addPlatform(255, 0, 0, 550, 100, screenGroup) 
	addPlatform(255, 128, 0, 450, 200, screenGroup) 
	addPlatform(0, 255, 255, 350, 300, screenGroup) 
	addPlatform(0, 0, 255, 250, 400, screenGroup) 
	addPlatform(111, 0, 255, 150, 500, screenGroup)
 
	local rainbow = display.newImage("rainbow.png")
	rainbow:translate(-100, -100)
	
	screenGroup:insert(rainbow)
	rainbow:toBack()
	background:toBack()
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