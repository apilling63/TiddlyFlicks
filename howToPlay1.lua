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
local physics = require "physics"
local boing = audio.loadSound("sounds/boing.mp3")
local translations = require "translations"

local visible = 0
local textBox
local textBox2
local staticWink
local finger
local fingerReset
local xVelocity = 0
local yVelocity = 0
local wink
local potLabel
local tiddlyLabel
local screenGroup
local swipeLength = 250
local speechBubble

local function moveTiddlyToStartPosition()
	wink.x = 75
	wink.y = 500 
end

-- what to do when the screen loads
function scene:createScene(event)
	screenGroup = self.view

	local background = utility.addBackground(screenGroup)

	staticWink = utility.addStaticWink(screenGroup, false)

	local floor = utility.addFloor(screenGroup, 880)

	wink = utility.loadImage("orangeWink.png")  
	moveTiddlyToStartPosition()
	physics.addBody(wink, "dynamic", dynamicMaterial)
	screenGroup:insert(wink)

	local potBack = utility.loadImage("potBack.png")
	potBack:translate(880, 570)
	screenGroup:insert(potBack)

	local potFront = utility.loadImage("potFront.png")
	potFront:translate(877, 580)
	screenGroup:insert(potFront)

	speechBubble = utility.loadImage("speechBubble.png")
	screenGroup:insert(speechBubble)
	utility.centreObjectX(speechBubble)
	speechBubble:translate(0, 200)

	textBox = utility.addBlackCentredText(translations.getPhrase("HOW TO 1"), 285, screenGroup, 45)
	textBox2 = utility.addBlackCentredText(translations.getPhrase("HOW TO 2"), 360, screenGroup, 45)

	tiddlyLabel = display.newText("TIDDLY", wink.x - 50, wink.y, "GoodDog", 50)
	tiddlyLabel:setTextColor(0,0,0)
	screenGroup:insert(tiddlyLabel)

	local potText = translations.getPhrase("HOW TO POT")

	potLabel = display.newText(potText, potFront.x - 30, potFront.y - 170, "GoodDog", 50)
	potLabel:setTextColor(0,0,0)
	screenGroup:insert(potLabel)

	finger = utility.loadImage("finger.png") 
	finger:translate(staticWink.x - 80, staticWink.y)
	screenGroup:insert(finger)
	finger:toBack()
	fingerReset = finger.y

	swiper = utility.loadImage("circle200.png")
	screenGroup:insert(swiper)
	swiper:setReferencePoint(display.TopCenterReferencePoint)
	swiper.alpha = 0.5
	swiper:toBack()
	swiper:translate(display.contentWidth - display.screenOriginX - 290, display.screenOriginY + 370) 

end

local function moveFinger(event)
	if movingUp then
		if finger.y > fingerReset then
			finger.y = finger.y - 4
			swiper.y = swiper.y - 4
		else
			movingUp = false
		end

	else
		if finger.y < (fingerReset + swipeLength) then
			finger.y = finger.y + 4
			swiper.y = swiper.y + 4
		else
			Runtime:removeEventListener("enterFrame", moveFinger)
			finger:toBack()
			swiper:toBack()
    	    		wink:setLinearVelocity(xVelocity , yVelocity) 
			utility.playSound(boing)
		end
	end
end

local function propel(xV, yV)
	movingUp = true
	finger.y = fingerReset + 200
	swiper.y = finger.y - 150
	textBox:toBack()
	textBox2:toBack()
	swiper:toFront()
	finger:toFront()
	speechBubble:toBack()
	Runtime:addEventListener("enterFrame", moveFinger)
	xVelocity = xV
	yVelocity = yV
end

local function click()
	--local phase = event.phase  

	--if "began" == phase then  

		if visible == 0 then
			textBox.text = translations.getPhrase("HOW TO 3")
			textBox2.text = translations.getPhrase("HOW TO 4")
			visible = 1
		elseif visible == 1 then
			textBox.text = translations.getPhrase("HOW TO 5")
			textBox2.text = translations.getPhrase("HOW TO 6")
			visible = 2
		elseif visible == 2 then
			tiddlyLabel:toBack()
			potLabel:toBack()
			propel(350, -350)
			visible = 3
		elseif visible == 3 then
			moveTiddlyToStartPosition()
			speechBubble:toFront()
			textBox:toFront()
			textBox2:toFront()
			textBox.text = translations.getPhrase("HOW TO 7") 
			textBox2.text = translations.getPhrase("HOW TO 8") 
			finger.y = fingerReset + 100
			fingerReset = fingerReset + 100
			visible = 4
		elseif visible == 4 then
			swipeLength = 250
			propel(100, -800)
			visible = 5
		elseif visible == 5 then
			moveTiddlyToStartPosition()
			speechBubble:toFront()
			textBox:toFront()
			textBox2:toFront()
			textBox.text = translations.getPhrase("HOW TO 9") 
			textBox2.text = translations.getPhrase("HOW TO 10") 
			finger.y = fingerReset - 170
			fingerReset = fingerReset - 170
			visible = 6
		elseif visible == 6 then
			propel(500, -150)
			visible = 7
		elseif visible == 7 then
			moveTiddlyToStartPosition()
			speechBubble:toFront()
			textBox:toFront()
			textBox2:toFront()
			textBox.text = translations.getPhrase("HOW TO 11") 
			textBox2.text = translations.getPhrase("HOW TO 12")  
			finger.y = fingerReset + 70
			fingerReset = fingerReset + 70
			swipeLength = 350
			visible = 8
		elseif visible == 8 then
			propel(450, -450)
			visible = 9
		elseif visible == 9 then
			Runtime:removeEventListener("enterFrame", moveFinger)
			visible = 10
			speechBubble:toFront()
			textBox:toFront()
			textBox2:toFront()
			textBox.text = translations.getPhrase("HOW TO 13") 
			textBox2.text = translations.getPhrase("HOW TO 14") 
		elseif visible == 10 then
			visible = 0

			if utility.hasSeenHowTo() then
				storyboard.gotoScene("menu1") 
			else
				storyboard.gotoScene("levelsScene")
				utility.setHasSeenHowTo()
			end
		end

		if visible ~= 0 then
			timer.performWithDelay(5500, click)	
		end
	--end
end

function scene:enterScene(event)
	storyboard.purgeScene(transitionData.currentScene)
	transitionData.currentScene = "howToPlay1"
	transitionData.nextScene = "menu1"
	timer.performWithDelay(4000, click)	
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