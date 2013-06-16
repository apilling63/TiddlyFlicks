-----------------------------------------------------------------------------------------
--
-- loading.lua
--
-----------------------------------------------------------------------------------------

-- allow this lua file to be used with storyboards
local storyboard = require "storyboard"
local scene = storyboard.newScene()
local transitionData = require "sceneTransitionData"
local utility = require "utility"
local persistent = require "persistent"
local training = require "training"
local myRevMob = require "myRevMob"
local loadingText

local initialise = function()
	utility.initialise()
	loadingText.text = "utilities initialised"
	training.initialise(0)
	loadingText.text = "store initialised"
	myRevMob.initialise()
	loadingText.text = "links initialised"
	timer.performWithDelay(50, storyboard.gotoScene("menu1"))
end

-- what to do when the screen loads
function scene:createScene(event)
	local screenGroup = self.view
	utility.addMenuBackground(screenGroup)

	local title = utility.loadImage("titleImage.png") 
	utility.centreObjectX(title)
	title.y = 10
	screenGroup:insert(title)

	loadingText = display.newText("Loading", 0, 475, "GoodDog", 75)
	loadingText:setTextColor(0,0,0)
	utility.centreObjectX(loadingText)
	screenGroup:insert(loadingText)
end

function scene:enterScene(event)
	transitionData.currentScene = "loading"
	timer.performWithDelay(50, initialise)
end

function scene:exitScene(event)
end

function scene:destroyScene(event)
end

scene:addEventListener("createScene", scene)
scene:addEventListener("enterScene", scene)
scene:addEventListener("exitScene", scene)
scene:addEventListener("destroyScene", scene)

return scene