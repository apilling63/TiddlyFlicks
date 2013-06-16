-----------------------------------------------------------------------------------------
--
-- level77.lua
--
-----------------------------------------------------------------------------------------

-- allow this lua file to be used with storyboards
local storyboard = require "storyboard"
local scene = storyboard.newScene()
local common = require ("common")
local utility = require ("utility")

local function addWaspAndBranchAndWood(xLocation, yLocation, screenGroup, addWasp) 
	local wood = utility.addWood(xLocation + 80, yLocation -900, screenGroup)

	common.addShortConveyer(screenGroup, xLocation, yLocation, 1)

	if addWasp then
		local wasp = utility.addWasp(screenGroup, xLocation + 50, yLocation+ 50)
		common.moveWasp(wasp, xLocation, yLocation - 50, xLocation + 200, yLocation + 150)
	end
end

-- what to do when the screen loads
function scene:createScene(event)
	screenGroup = self.view
	common.createSceneCommon(screenGroup, 200, "level77", "level35", storyboard)

	local wood = utility.addWood(250, 270, screenGroup)

	addWaspAndBranchAndWood(250, 250, screenGroup, true)
	addWaspAndBranchAndWood(400, 350, screenGroup)
	addWaspAndBranchAndWood(550, 450, screenGroup, true)
	addWaspAndBranchAndWood(700, 550, screenGroup)
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