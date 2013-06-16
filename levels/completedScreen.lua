-----------------------------------------------------------------------------------------
--
-- completedScene.lua
--
-----------------------------------------------------------------------------------------

-- allow this lua file to be used with storyboards
local storyboard = require "storyboard"
local scene = storyboard.newScene()
local transitionData = require "sceneTransitionData"
local utility = require "utility"
local applause = audio.loadSound("sounds/applause.mp3")

local menuButton

local function backToMenu()
	transitionData.currentScene = "completedScene"
	transitionData.nextScene = "menu1"

	storyboard.gotoScene(transitionData.nextScene)
end

-- what to do when the screen loads
function scene:createScene(event)
	local screenGroup = self.view
	
	utility.addBackground(screenGroup)

	local wink = utility.loadImage("winky2.png")
	utility.centreObjectX(wink)
	wink.y = 25
	screenGroup:insert(wink)

	utility.addBlackCentredText("YOU'RE A TIDDLY MASTER!!", 250, screenGroup, 80)

	utility.addCentredText("Congratulations upon helping Tiddly escape from the country!", 325, screenGroup, 40)

	utility.addBlackCentredText("Look out for game updates and new games with Tiddly!!", 400, screenGroup, 50)

	menuButton = utility.addMenuButton(screenGroup, 0, 500)
	utility.centreObjectX(menuButton)
end


-- add all the event listening
function scene:enterScene(event)
	storyboard.purgeScene(transitionData.currentScene)
	menuButton:addEventListener("touch", backToMenu)

	utility.playSound(applause)

end

function scene:exitScene(event)
	menuButton:removeEventListener("touch", backToMenu)
end

function scene:destroyScene(event)
end

scene:addEventListener("createScene", scene)
scene:addEventListener("enterScene", scene)
scene:addEventListener("exitScene", scene)
scene:addEventListener("destroyScene", scene)

return scene