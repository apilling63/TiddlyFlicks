-----------------------------------------------------------------------------------------
--
-- level75.lua
--
-----------------------------------------------------------------------------------------

-- allow this lua file to be used with storyboards
local storyboard = require "storyboard"
local scene = storyboard.newScene()
local common = require ("common")
local utility = require ("utility")
local time = 0
local time2 = 0
local barrierPresent = 1
local barrierPresent2 = 1

local screenGroup
local bolt
local bolt2

-- what to do when the screen loads
function scene:createScene(event)
	screenGroup = self.view
	common.createSceneCommon(screenGroup, 200, "level75", "level24", storyboard)
	bolt = utility.addBolt(450, screenGroup)
	bolt2 = utility.addBolt(750, screenGroup)
	common.addCloud(550, 425, 580, nil, screenGroup)
	common.addLeaf(250, 400, 570, nil, screenGroup)

	--local wasp = utility.addWasp(screenGroup, 250, 300)
	--common.moveWasp(wasp, 250, 250, 350, 350)

	local wasp2 = utility.addWasp(screenGroup, 650, 350)
	common.moveWasp(wasp2, 600, 300, 750, 600)
end

local function removeAddBarrier(event)

	if event.time - time > 1000 then
		time = event.time
		barrierPresent = 0
		bolt.isVisible = false
		utility.removeBodyFromPhysics(bolt)
	elseif event.time - time > 590 and barrierPresent == 0 then
		time = event.time
		barrierPresent = 1
		bolt.isVisible = true
		utility.addBodyToPhysics(bolt)
	end

	if event.time - time2 > 850 then
		time2 = event.time
		barrierPresent2 = 0
		bolt2.isVisible = false
		utility.removeBodyFromPhysics(bolt2)
	elseif event.time - time2 > 640 and barrierPresent2 == 0 then
		time2 = event.time
		barrierPresent2 = 1
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