-----------------------------------------------------------------------------------------
--
-- levelsScene.lua
--
-----------------------------------------------------------------------------------------

-- allow this lua file to be used with storyboards
local storyboard = require "storyboard"
local scene = storyboard.newScene()
local transitionData = require "sceneTransitionData"
local utility = require "utility"
local persistent = require "persistent"
local training = require "training"
local levelMappings = require "levelMappings"
local translations = require "translations"

local os = require "os"

local buttons
local menuButton
local nextButton
local endTimer
local timerText
local unlocked1 = false
local unlocked2 = false

local gameNoise = audio.loadSound("sounds/country_sounds.mp3")

local function doReturn(event)
	if event.phase == "began" then
		print("doing return")
		transitionData.nextScene = "menu1"
		transitionData.currentScene = "levelsScene"
		storyboard.gotoScene( "menu1") 
	end
end

local function goToLevel(event)
	if event.phase == "began" then

		print("going to level")
		event.target.boxText:setTextColor(255, 255, 0)
		local levelName = utility.getLevelName(event.target.level)				transitionData.nextScene = levelName
		transitionData.currentScene = "levelsScene"

		local closure = function()
			utility.stopSound()
			utility.playSoundWithOptions(gameNoise, {loops = -1})
			storyboard.gotoScene(transitionData.nextScene) 
		end

		timer.performWithDelay(50, closure)
	end
end

local function goToPrevious(event)
	if event.phase == "began" then
		print("going to previous buttons")

		for i=1,#buttons do
			local button = buttons[i] 
			button:translate(1500, 0) 
			button.star1:translate(1500, 0)
			button.star2:translate(1500, 0) 
			button.star3:translate(1500, 0) 
			button.boxText:translate(1500, 0) 

		end

		if nextButton.isVisible and previousButton.isVisible then
			previousButton.isVisible = false
			timerText.text = translations.getPhrase("Escape from the Country")
			lock.isVisible = false
		elseif previousButton.isVisible then
			nextButton.isVisible = true
			timerText.text = translations.getPhrase("Escape from the Country") .. " 2"
			comingSoonText.isVisible = false

			if unlocked1 == false then
				lock.isVisible = true
			end
		end
	end
end

local function goToNext(event)
	if event.phase == "began" then
		print("going to next buttons")

		for i=1,#buttons do
			local button = buttons[i] 
			button:translate(-1500, 0) 
			button.star1:translate(-1500, 0)
			button.star2:translate(-1500, 0) 
			button.star3:translate(-1500, 0) 
			button.boxText:translate(-1500, 0) 

		end

		if nextButton.isVisible and previousButton.isVisible then
			nextButton.isVisible = false
			timerText.text = translations.getPhrase("Escape from the Moon")
			comingSoonText.isVisible = true
			lock.isVisible = false
		elseif nextButton.isVisible then
			previousButton.isVisible = true
			timerText.text = translations.getPhrase("Escape from the Country") .. " 2"

			if unlocked1 == false then
				print("making lock visible")
				lock.isVisible = true
			end
		end
	end
end

local function addStars(numStars, screenGroup, startX, yLocation, box)
	local star = utility.loadImage("smallStar.png")
	star:translate(startX + 15, yLocation)
	screenGroup:insert(star)
	box.star1 = star

	local star2 = utility.loadImage("smallStar.png")
	star2:translate(startX + 40, yLocation)
	screenGroup:insert(star2)
	box.star2 = star2

	local star3 = utility.loadImage("smallStar.png")
	star3:translate(startX + 65, yLocation)
	screenGroup:insert(star3)
	box.star3 = star3

	if numStars < 3 then
		star3:setFillColor(50,50,50)
	end

	if numStars < 2 then
		star2:setFillColor(50,50,50)
	end

	if numStars < 1 then
		star:setFillColor(50,50,50)
	end
end

local function addLevelButtons(topLimit, xOffset, foundZero, screenGroup, unlocked)
	local row = 0
	local position = 0

	for i= topLimit - 31, topLimit do 

		if i % 8 == 1 then
			row = row + 1
			position = 0
		end

		local currentStars = 0
		local firstZeroFound = false

		if unlocked then
			currentStars = utility.getStarsForLevelIndex(i)

			if foundZero == false and currentStars == 0 then
				firstZeroFound = true
				foundZero = true
			end
		end

		print(currentStars .. " for level " .. i)

		local xBoxPosition = (105 * position) + 70 + xOffset
		local yBoxPosition = (100 * row) + 5
		local box = utility.loadImage("wink50.png")
		box:translate(xBoxPosition, yBoxPosition)

		local boxText = display.newText(i, xBoxPosition - 10, yBoxPosition -5, "GoodDog", 65)
		boxText:translate((100 - boxText.width) / 2, 0)
		screenGroup:insert(box)
		screenGroup:insert(boxText)
		box.boxText = boxText
		addStars(currentStars, screenGroup, xBoxPosition - 10, yBoxPosition + 75, box)

		position = position + 1
		buttons[i] = box

		if currentStars > 0 or firstZeroFound then
			box.canClick = true
		else
			box:setFillColor(100, 100, 100)
			box.canClick = false
		end

	end

	return foundZero
end

-- what to do when the screen loads
function scene:createScene(event)
	local screenGroup = self.view
	background = utility.addMenuBackground(screenGroup)
	buttons = {}

	timerText = display.newText(translations.getPhrase("Escape from the Country"), 0, 0, "GoodDog", 70)

	timerText:setTextColor(0,0,0)
	utility.centreObjectX(timerText)
	timerText.y = 25
	screenGroup:insert(timerText)

	unlocked1 = utility.hasUnlocked1()
	unlocked2 = utility.hasUnlocked2()

	local foundZero = addLevelButtons(32, 0, false, screenGroup, true)
	foundZero = addLevelButtons(64, 1500, foundZero, screenGroup, unlocked1)
	foundZero = addLevelButtons(96, 3000, foundZero, screenGroup, unlocked2)

	menuButton = utility.loadImage("menuButton.png")
	utility.centreObjectX(menuButton)
	menuButton:translate(-150, 525)
	screenGroup:insert(menuButton)

	nextButton = utility.loadImage("nextButton.png")
	utility.centreObjectX(nextButton)
	nextButton:translate(300, 525)
	screenGroup:insert(nextButton)

	previousButton = utility.loadImage("previousButton.png")
	utility.centreObjectX(previousButton)
	previousButton:translate(150, 525)
	screenGroup:insert(previousButton)
	previousButton.isVisible = false

	lock = utility.loadImage("lock.png")
	utility.centreObjectX(lock)
	lock:translate(0, 110)
	screenGroup:insert(lock)
	lock.isVisible = false

	comingSoonText = display.newText(translations.getPhrase("COMING SOON"), 0, 125, "GoodDog", 180)
	comingSoonText:setTextColor(255,255,0)
	utility.centreObjectX(comingSoonText)
	comingSoonText.isVisible = false
	screenGroup:insert(comingSoonText)
end

local function returnToMenu()
	print("going to menu")
	transitionData.currentScene = "levelsScene"
	transitionData.nextScene = "menu1"
	storyboard.gotoScene("menu1")  
end

-- Handler that gets notified when the alert closes
local function goToMenu( event )
	if "began" == event.phase then
		returnToMenu()
	end
end

local function refreshPage()
	print("refreshing page")
	transitionData.currentScene = "levelsScene"
	transitionData.nextScene = "levelsScene"
	storyboard.gotoScene("doNothingScene") 
end

local function buyExtraLevels1(event)
	if "began" == event.phase then
		training.purchase(1, refreshPage)
	end
end

function scene:enterScene(event)
	storyboard.purgeScene(transitionData.currentScene)
	for i=1,#buttons do
		local button = buttons[i] 

		if button.canClick then
			button.level = i
			button:addEventListener("touch", goToLevel) 
		end
	end

	menuButton:addEventListener("touch", goToMenu) 
	nextButton:addEventListener("touch", goToNext)
	previousButton:addEventListener("touch", goToPrevious)
	lock:addEventListener("touch", buyExtraLevels1)

end

function scene:exitScene(event)
	for i=1,#buttons do
		local button = buttons[i] 
		button:removeEventListener("touch", goToLevel) 
	end

	menuButton:removeEventListener("touch", goToMenu) 
	nextButton:removeEventListener("touch", goToNext) 
	previousButton:removeEventListener("touch", goToPrevious)
	lock:removeEventListener("touch", buyExtraLevels1)

end

function scene:destroyScene(event)
end

scene:addEventListener("createScene", scene)
scene:addEventListener("enterScene", scene)
scene:addEventListener("exitScene", scene)
scene:addEventListener("destroyScene", scene)

return scene