-----------------------------------------------------------------------------------------
--
-- level23.lua
--
-----------------------------------------------------------------------------------------

-- allow this lua file to be used with storyboards
local storyboard = require "storyboard"
local scene = storyboard.newScene()
local common = require ("common")
local utility = require ("utility")
local time = 0
local barrierPresent = 1

-- what to do when the screen loads
function scene:createScene(event)
	screenGroup = self.view
	common.createSceneCommon(screenGroup, 200, "level23", "level24", storyboard)
	bolt = utility.addBolt(760, screenGroup)
end

local function removeAddBarrier(event)

	if event.time - time > 1000 then
		time = event.time
		barrierPresent = 0
		bolt.isVisible = false
		utility.removeBodyFromPhysics(bolt)
	elseif event.time - time > 700 and barrierPresent == 0 then
		time = event.time
		barrierPresent = 1
		bolt.isVisible = true
		utility.addBodyToPhysics(bolt)
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