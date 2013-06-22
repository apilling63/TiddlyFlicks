-----------------------------------------------------------------------------------------
--
-- credits.lua
--
-----------------------------------------------------------------------------------------

-- allow this lua file to be used with storyboards
local storyboard = require "storyboard"
local scene = storyboard.newScene()
local transitionData = require "sceneTransitionData"
local utility = require "utility"

local function doReturn(event)
	if event.phase == "began" then
		transitionData.nextScene = "menu1"
		storyboard.gotoScene( "menu1" ) 
	end
end

-- what to do when the screen loads
function scene:createScene(event)
	local screenGroup = self.view
	background = utility.addMenuBackground(screenGroup) 
	utility.addBlackCentredText("SOUND EFFECTS - www.freesfx.co.uk", 160, screenGroup, 40)
	utility.addBlackCentredText("GRAPHIC DESIGN  - Chris Lock - www.cornishlocky.co.uk", 100, screenGroup, 40)
	utility.addBlackCentredText("GAME DESIGN AND CODING - Adam Pilling", 40, screenGroup, 40)
	utility.addBlackCentredText("MENU MUSIC - Matt Johnson - www.newgrounds.com/audio/listen/268982", 220, screenGroup, 40)

end


function scene:enterScene(event)
	storyboard.purgeScene(transitionData.currentScene)
	transitionData.currentScene = "credits2"
	background:addEventListener("touch", doReturn) 
end

function scene:exitScene(event)
	background:removeEventListener("touch", doReturn)
end

function scene:destroyScene(event)
end

scene:addEventListener("createScene", scene)
scene:addEventListener("enterScene", scene)
scene:addEventListener("exitScene", scene)
scene:addEventListener("destroyScene", scene)

return scene