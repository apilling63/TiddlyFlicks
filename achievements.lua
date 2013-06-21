-----------------------------------------------------------------------------------------
--
-- achievements.lua
--
-----------------------------------------------------------------------------------------

-- allow this lua file to be used with storyboards
local storyboard = require "storyboard"
local scene = storyboard.newScene()
local transitionData = require "sceneTransitionData"
local utility = require "utility"
local persistent = require "persistent"
local translations = require "translations"

local menuButton
local nextButton
local previousButton

local function addAchievement(yLocation, firstRowBool, achievementText1, achievementText2, achievementText3, hasAchieved, screenGroup, toInsert)
	local achievementPic = utility.loadImage("achievements.png")

	local xLocation = (display.contentWidth / 2) + 30

	if firstRowBool then
		xLocation = 50
	end

	achievementPic:translate(xLocation, yLocation)
	screenGroup:insert(achievementPic)

	local textObject3 = display.newText(achievementText3, xLocation + 130, yLocation -15, "GoodDog", 50)
	screenGroup:insert(textObject3)
	textObject3:setTextColor(255,255,0)


	local textObject = display.newText(achievementText1, xLocation + 130, yLocation + 30, "GoodDog", 45)
	screenGroup:insert(textObject)
	textObject:setTextColor(0,0,0)

	local textObject2

	if achievementText2 then
		textObject2 = display.newText(achievementText2, xLocation + 130, yLocation + 60, "GoodDog", 45)
		screenGroup:insert(textObject2)
		textObject2:setTextColor(0,0,0)
	end

	if hasAchieved == false then
		achievementPic.alpha = 0.65
	else
		achievementPic:setFillColor(255,255,0)
	end

	achievementPic.text1 = textObject
	achievementPic.text2 = textObject2
	achievementPic.text3 = textObject3

	table.insert(toInsert, achievementPic)
end

local function showAll(toShow)

    	for i=1,#toShow do
		local obj = toShow[i]

		obj.isVisible = true;
		obj.text1.isVisible = true
		obj.text3.isVisible = true
		
		if obj.text2 then
			obj.text2.isVisible = true
	
		end
	end

end

local function hideAll(toHide)

    	for i=1,#toHide do
		local obj = toHide[i]

		obj.isVisible = false;
		obj.text1.isVisible = false
		obj.text3.isVisible = false
		
		if obj.text2 then
			obj.text2.isVisible = false
	
		end
	end

end

local function goToPrevious(event)
	if event.phase == "began" then
		hideAll(page2)
		showAll(page1)
		previousButton.isVisible = false
		nextButton.isVisible = true

	end
end

local function goToNext(event)
	if event.phase == "began" then
		hideAll(page1)
		showAll(page2)
		nextButton.isVisible = false
		previousButton.isVisible = true

	end
end


-- what to do when the screen loads
function scene:createScene(event)
	local screenGroup = self.view
	local background = utility.addMenuBackground(screenGroup)

	local titleText = utility.addBlackCentredText("Tiddly Badges", 15, screenGroup, 80)

	page1 = {}
	page2 = {}

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

	addAchievement(120, true, "3 holes in one", 	nil, 		"Tiddly Flickster", utility.hasAchieved3HIO(), screenGroup, page1)
	addAchievement(260, true, "10 holes in one", 	nil, 		"Tiddly Sharpshooter", utility.hasAchieved10HIO(), screenGroup, page1)
	addAchievement(400, true, "100 holes in one", 	nil, 		"Tiddly Dynamo", utility.hasAchieved100HIO(), screenGroup, page1)
	addAchievement(120, false, "3 consecutive levels", "without hazard", "Tiddly Dodger", utility.hasAchieved3Consecutive(), screenGroup, page1)
	addAchievement(260, false, "10 consecutive levels", "without hazard", "Tiddly Ninja", utility.hasAchieved10Consecutive(), screenGroup, page1)
	--addAchievement(400, false, "Find 3 secret", "stars", 		"Tiddly Explorer", false, screenGroup, page1)

	--addAchievement(120, false, "Find 10 secret", "stars", 		"Tiddly Columbus", false, screenGroup, page2)
	addAchievement(400, false, "Complete 32 levels", nil, 		"Tiddly Expert", utility.hasCompleted32Levels(), screenGroup, page1)
	addAchievement(120, true, "Complete 20 levels", "with 3 stars", "Tiddly Aficionado", utility.hasCompleted20LevelsWith3Stars(), screenGroup, page2)
	addAchievement(260, true, "Complete 64 levels", nil, 		"Tiddly Champion", utility.hasCompleted64Levels(), screenGroup, page2)
	addAchievement(120, false, "Complete 32 levels", "with 3 stars", "Tiddly Master", utility.hasCompleted32LevelsWith3Stars(), screenGroup, page2)
	addAchievement(260, false, "Complete 64 levels", "with 3 stars", "Tiddly God", utility.hasCompleted64LevelsWith3Stars(), screenGroup, page2)

	hideAll(page2)
end

local function returnToMenu()
	print("going to menu")
	transitionData.nextScene = "menu1"
	storyboard.gotoScene("menu1")  
end

-- Handler that gets notified when the alert closes
local function goToMenu( event )
	if "began" == event.phase then
		returnToMenu()
	end
end




function scene:enterScene(event)
	storyboard.purgeScene(transitionData.currentScene)
	transitionData.currentScene = "achievements"
	menuButton:addEventListener("touch", goToMenu) 
	nextButton:addEventListener("touch", goToNext)
	previousButton:addEventListener("touch", goToPrevious)
end

function scene:exitScene(event)
	menuButton:removeEventListener("touch", goToMenu) 
	nextButton:removeEventListener("touch", goToNext) 
	previousButton:removeEventListener("touch", goToPrevious)
end

function scene:destroyScene(event)
end

scene:addEventListener("createScene", scene)
scene:addEventListener("enterScene", scene)
scene:addEventListener("exitScene", scene)
scene:addEventListener("destroyScene", scene)

return scene