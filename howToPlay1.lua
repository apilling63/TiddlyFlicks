-----------------------------------------------------------------------------------------
--
-- howToPlay1.lua
--
-----------------------------------------------------------------------------------------

-- allow this lua file to be used with storyboards
local storyboard = require "storyboard"
local scene = storyboard.newScene()
local common = require ("common")
local transitionData = require "sceneTransitionData"
local utility = require "utility"

local visible = 1
local slowArc
local fastArc
local shallowArc
local steepArc
local textBox
local staticWink
local finger
local fingerSpeed
local fingerReset
local numLivesPic
local numLivesText

-- what to do when the screen loads
function scene:createScene(event)
	local screenGroup = self.view

	local background = utility.addBackground(screenGroup)

	nextButton = utility.loadImage("nextButton.png")
	nextButton:translate(20, 20)
	screenGroup:insert(nextButton)

	staticWink = utility.loadImage("winky2.png")
	staticWink:translate(display.contentWidth - display.screenOriginX - 285, display.screenOriginY + 20)

	screenGroup:insert(staticWink)

	local floor = utility.addFloor(screenGroup, 880)

	local wink = utility.loadImage("orangeWink.png")  
	wink:translate(floor.x -270, floor.y - 30) 
	screenGroup:insert(wink)

	slowArc = utility.loadImage("slowArc.png") 
	slowArc:translate(wink.x - 10, wink.y -100)
	screenGroup:insert(slowArc)
	slowArc:toBack()

	fastArc = utility.loadImage("fastArc.png") 
	fastArc:translate(wink.x - 20, wink.y - 305)
	screenGroup:insert(fastArc)
	fastArc:toBack()

	shallowArc = utility.loadImage("shallow.png") 
	shallowArc:translate(wink.x, wink.y - 100)
	screenGroup:insert(shallowArc)
	shallowArc:toBack()

	steepArc = utility.loadImage("steep.png") 
	steepArc:translate(wink.x - 10, wink.y - 445)
	screenGroup:insert(steepArc)
	steepArc:toBack()

	local potBack = utility.loadImage("potBack.png")
	potBack:translate(880, 570)
	screenGroup:insert(potBack)

	local potFront = utility.loadImage("potFront.png")
	potFront:translate(877, 580)
	screenGroup:insert(potFront)

	textBox = display.newText("The aim of the game is to flick Tiddly into the pot", 0, 0, 600, 0, "GoodDog", 55)
	utility.centreObjectX(textBox)
	textBox.y = 200
	screenGroup:insert(textBox)
	textBox:setTextColor(0,0,0)

	tiddlyLabel = display.newText("TIDDLY", wink.x - 50, wink.y - 70, "GoodDog", 50)
	screenGroup:insert(tiddlyLabel)

	potLabel = display.newText("POT", potFront.x - 30, potFront.y - 140, "GoodDog", 50)
	screenGroup:insert(potLabel)

	finger = utility.loadImage("finger.png") 
	finger:translate(staticWink.x - 35, staticWink.y)
	screenGroup:insert(finger)
	finger:toBack()
	fingerSpeed = 4
	fingerReset = finger.y

	staticWink:toBack()

end

local function moveFinger(event)

	if finger.y < fingerReset + 200 then
		finger.y = finger.y + fingerSpeed
	else
		finger.y = fingerReset
	end
end

local function click(event)
	local phase = event.phase  

	if "began" == phase then  
		if visible == 1 then
			staticWink:toFront()
			finger:toFront()
			textBox.text = "When his face appears, swipe it!!" 
			Runtime:addEventListener("enterFrame", moveFinger)
			visible = 2
		elseif visible == 2 then
			tiddlyLabel:toBack()
			potLabel:toBack()
			fastArc:toFront()
			slowArc:toFront()
			textBox.text = "The faster you swipe, the further Tiddly travels!" 
			visible = 3
			fingerSpeed = 6
		elseif visible == 3 then
			textBox.text = "Swipe from the bottom for a steep trajectory" 
			textBox.x = textBox.x + 100
			fingerReset = fingerReset + 50
			fingerSpeed = 4
			fastArc:toBack()
			slowArc:toBack()
			steepArc:toFront()
			textBox:toFront()
			finger:toFront()
			visible = 4
		elseif visible == 4 then
			textBox.text = "Swipe from the top for a shallow trajectory" 
			textBox.x = textBox.x - 100
			fingerReset = fingerReset - 125
			steepArc:toBack()
			shallowArc:toFront()
			visible = 5
		elseif visible == 5 then
			Runtime:removeEventListener("enterFrame", moveFinger)
			visible = 6
			staticWink:toBack()
			finger:toBack()
			shallowArc:toBack()
			textBox.text = "GOOD LUCK!"
		elseif visible == 6 then
			visible = 1
			storyboard.gotoScene("menu1") 
		end
	end
end

function scene:enterScene(event)
	storyboard.purgeScene(transitionData.currentScene)
	transitionData.currentScene = "howToPlay1"
	transitionData.nextScene = "menu1"
  	Runtime:addEventListener("touch", click) 
end

function scene:exitScene(event)
	Runtime:removeEventListener("touch", click) 
end

function scene:destroyScene(event)
end

scene:addEventListener("createScene", scene)
scene:addEventListener("enterScene", scene)
scene:addEventListener("exitScene", scene)
scene:addEventListener("destroyScene", scene)

return scene