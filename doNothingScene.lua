-----------------------------------------------------------------------------------------
--
-- transitionLevel.lua
--
-----------------------------------------------------------------------------------------

-- allow this lua file to be used with storyboards
local storyboard = require "storyboard"
local transitionData = require "sceneTransitionData"
local scene = storyboard.newScene()

local function changeScene()
	transitionData.currentScene = "transitionLevel"
	storyboard.gotoScene(transitionData.nextScene)
end

-- what to do when the screen loads
function scene:createScene(event)
end

-- add all the event listening
function scene:enterScene(event)
	storyboard.purgeScene(transitionData.currentScene)
	changeScene()
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


