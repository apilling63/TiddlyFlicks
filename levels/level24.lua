-----------------------------------------------------------------------------------------
--
-- level24.lua
--
-----------------------------------------------------------------------------------------

-- allow this lua file to be used with storyboards
local storyboard = require "storyboard"
local scene = storyboard.newScene()
local common = require ("common")
local utility = require ("utility")

local time1 = 0
local time2 = 0

-- what to do when the screen loads
function scene:createScene(event)
	screenGroup = self.view
	common.createSceneCommon(screenGroup, 400, "level24", "level25", storyboard)
	bolt1 = utility.addBolt(500, screenGroup)
	bolt2 = utility.addBolt(650, screenGroup)
end

local function removeAddBarrier(event)

	if event.time - time1 > 1000 then
		time1 = event.time
		bolt1.isVisible = false
		utility.removeBodyFromPhysics(bolt1)
	elseif event.time - time1 > 800 and bolt1.isVisible == false then
		time1 = event.time
		bolt1.isVisible = true
		utility.addBodyToPhysics(bolt1)
	end

	if event.time - time2 > 800 then
		time2 = event.time
		bolt2.isVisible = false
		utility.removeBodyFromPhysics(bolt2)
	elseif event.time - time2 > 700 and bolt2.isVisible == false then
		time2 = event.time
		bolt2.isVisible = true
		utility.addBodyToPhysics(bolt2)
	end
end

-- add all the event listening
function scene:enterScene(event)
	common.enterSceneCommon()
	Runtime:addEventListener( "enterFrame", removeAddBarrier )
end

function scene:exitScene(event)
	common.exitSceneCommon()
	Runtime:removeEventListener( "enterFrame", removeAddBarrier )
end

function scene:destroyScene(event)
end

scene:addEventListener("createScene", scene)
scene:addEventListener("enterScene", scene)
scene:addEventListener("exitScene", scene)
scene:addEventListener("destroyScene", scene)

return scene