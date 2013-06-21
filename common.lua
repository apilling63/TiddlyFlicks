-----------------------------------------------------------------------------------------
--
-- common.lua
--
-----------------------------------------------------------------------------------------

local physics = require "physics"  
physics.start()  
physics.setGravity(0, 9.81)
physics.setScale(80)  -- 80 pixels per meter  

local persistent = require "persistent"  
local utility = require "utility"  
local math = require "math"  
local training = require "training"
local levelMappings = require "levelMappings"
local json = require("json")

local t = {}
local transitionData = require "sceneTransitionData"

local dragStartY = 0  
local dragStartTime = 0  
local dragMultiplier = 0.7
local currentScene
local completedScene
local storyboard
local waitingToRestart = 0
local numFlicks = 0
local clinkSound = audio.loadSound("sounds/bounce.mp3")
local yes = audio.loadSound("sounds/yes.mp3")
local applause = audio.loadSound("sounds/applause.mp3")

local ohNo = audio.loadSound("sounds/falling.mp3")
local ouch = audio.loadSound("sounds/yelp.wav")
local boing = audio.loadSound("sounds/boing.mp3")
local teleport = audio.loadSound("sounds/teleport.wav")
local openCover = audio.loadSound("sounds/openCover.wav")
local buzz = audio.loadSound("sounds/buzz.mp3")
local woosh = audio.loadSound("sounds/woosh.mp3")
local ding = audio.loadSound("sounds/ding.mp3")
local metal = audio.loadSound("sounds/metal.wav")

local outOfBounds = false
local screenGp
local levelCompleted = false
local numStars
local levelIndex
local staticStart = 20
local staticEnd = 320

local helpText
local helpText2

local angleText
local speedText
local swipeCircle
local previousY
local angle = 180
local dragStartY

local function goToNext()
	storyboard.gotoScene(transitionData.nextScene) 
end

local function fadeSpeedAndAngleText(event)
	if speedText.alpha > 0 then

		if speedText.alpha < 0.01 then
			speedText.alpha = 0
		else
			speedText.alpha = speedText.alpha - 0.005
		end
	end

	if angleText.alpha > 0 then
		if angleText.alpha < 0.01 then
			angleText.alpha = 0
		else
			angleText.alpha = angleText.alpha - 0.005

		end
	end
end

local function fadeHelpText(event)
	if helpText and helpText.alpha > 0 then
		helpText:toFront()

		if helpText.alpha < 0.004 then
			helpText.alpha = 0
		else
			helpText.alpha = helpText.alpha - 0.002
		end
	end

	if helpText2 and helpText2.alpha > 0 then
		helpText2:toFront()

		if helpText2.alpha < 0.004 then
			helpText2.alpha = 0
		else
			helpText2.alpha = helpText2.alpha - 0.002
		end
	end
end

t.setHelpText = function(text1, text2)
	helpText.text = text1
	helpText2.text = text2
	helpText:setTextColor(0,0,0)
	helpText2:setTextColor(0,0,0)
	utility.centreObjectX(helpText)
	screenGp:insert(helpText)
	utility.centreObjectX(helpText2)
	screenGp:insert(helpText2)
end

local function resetLevel() 
	outOfBounds = false
	levelCompleted = false

	waitingToRestart = 0
	numFlicks = 0

	flicksPerStar = {}
	flicksPerStar.two = 4
	flicksPerStar.three = 2
end

local function addStar(xLocation, isLit)
	utility.playSound(woosh)

	print("adding star at " .. xLocation)

	if isLit then
		star = utility.loadImage("yellowStar.png") 
	else 
		star = utility.loadImage("emptyStar.png") 
	end

	star:setReferencePoint(display.TopCenterReferencePoint)
	star.x = xLocation
	star.y = 150	
	screenGp:insert(star)
end

local function addStarOne()
	addStar((display.contentWidth / 2) - 100, true)
end

local function addStarTwo()
	addStar(display.contentWidth / 2, numStars > 1)
end

local function addStarThree()
	addStar((display.contentWidth / 2) + 100, numStars > 2)
end

local function moveOutOfBoundsText()
	if (outOfBounds or levelCompleted) and (outOfBoundsText.x > (display.contentWidth / 2)) then
		if ((outOfBoundsText.x - 15) > (display.contentWidth / 2)) then
			outOfBoundsText.x = outOfBoundsText.x - 15
		else
			outOfBoundsText.x = (display.contentWidth / 2)
			Runtime:removeEventListener("enterFrame", moveOutOfBoundsText)

			if outOfBounds then
				utility.playSound(ding)

				utility.centreObjectX(restartButton)
				restartButton:translate(-100, 0)
				restartButton.y = 500
				restartButton:toFront()

				utility.centreObjectX(menuButton)
				menuButton:translate(100, 0)
				menuButton.y = 500
				menuButton:toFront()

				local backToStartText = display.newText("Tiddly must head back to the start", 0, 250, "GoodDog", 60)
				utility.centreObjectX(backToStartText)
				screenGp:insert(backToStartText)
			end
		end
		
	end
	
end

local function levelChangeCommon()
	local hasEarnedBadge = utility.completedOrFailedToEarnBadge(levelCompleted, levelIndex)

	background:toFront()
	background.alpha = 0.9
	outOfBoundsText:toFront()
	Runtime:addEventListener("enterFrame", moveOutOfBoundsText)

	return hasEarnedBadge
end

local function returnToMenu()
	print("return to menu")
	transitionData.currentScene = currentScene
	transitionData.nextScene = "menu1"
	storyboard.gotoScene("menu1") 
end

local function unlock1(event)
	if "clicked" == event.action then

        	local i = event.index

	        if 1 == i then

			local closure = function()
				training.purchase(1, goToNext)
			end
			
			timer.performWithDelay(10, closure)
		else
			returnToMenu()
		end
	end
end

local function hitHazard(text)
	if waitingToRestart == 0 then
		activeWink.isVisible = false
		activeWink.name = "donotuse"
		waitingToRestart = 1 
		print("hit hazard")
		outOfBounds = true

		outOfBoundsText.text = text
		levelChangeCommon()
	end
end

local function hitWasp()
	utility.playSound(ouch)
	hitHazard("TIDDLY GOT STUNG!!")
end

local function hitBolt()
	utility.playSound(ouch)
	hitHazard("TIDDLY GOT SHOCKED!!")
end

local function goneOutOfBounds()
	utility.playSound(ohNo)
	hitHazard("OUT OF BOUNDS!!")
end

local function insertStars()
	local currentStars = utility.getStarsForLevelIndex(levelIndex)

	print("Previous best " .. currentStars .. " stars. This " .. numStars)

	if numStars > currentStars then
		print("persisting " .. numStars .. " stars for " .. currentScene)
		persistent.saveModule(currentScene, numStars)
		utility.setStarsForLevelIndex(numStars, levelIndex)
	end
end

local function levelComplete()
	utility.playSound(yes)
	utility.playSound(applause)

	outOfBoundsText.text = "A TIDDLY TRIUMPH!!"
	levelCompleted = true

	local hasAchieved2 = levelChangeCommon()

	transitionData.currentScene = currentScene 
	transitionData.nextScene = completedScene 
	
	menuButton.isVisible = false
	restartButton.isVisible = false

	if numFlicks <= flicksPerStar.three then
		numStars = 3
	elseif numFlicks <= flicksPerStar.two then
		numStars = 2
	else
		numStars = 1
	end

	insertStars()

	timer.performWithDelay(2000, addStarOne)
	timer.performWithDelay(2300, addStarTwo)
	timer.performWithDelay(2600, addStarThree)

	local closure = function()
		local goToNextText = display.newText("Have a go at the next level!", 0, 350, "GoodDog", 60)
		utility.centreObjectX(goToNextText)
		screenGp:insert(goToNextText)
		utility.playSound(ding)
			
		if levelIndex == 32 and utility.hasUnlocked1() == false then
			utility.playSound(applause)
			native.showAlert( "TIDDLY MASTER!!", "Congratulations upon completing the first 32 levels of Tiddly Flicks Escape from the Country - you're a true Tiddly Master! Continue the fun by unlocking some more levels", { "Unlock", "Maybe later" }, unlock1 )
		else
			if levelIndex % 4 == 0 and utility.hasPosted(levelIndex) == false then
                		--utility.postToFacebook("I just completed level " .. levelIndex .. " on Tiddly Flicks", levelIndex)
			end
			
			local hasAchieved = false
			
			if numFlicks == 1 then
				hasAchieved = utility.hasEarnedBadgesWithHoleInOne()
			end

			if hasAchieved or hasAchieved2 then
				local achievementPic = utility.loadImage("achievements.png")
				screenGp:insert(achievementPic)
				achievementPic:translate(700, 200)
				achievementPic:setFillColor(255,255,0)
			end

			menuButton.isVisible = true
			restartButton.isVisible = true
			nextButton.isVisible = true

			utility.centreObjectX(restartButton)
			restartButton:translate(-150, 0)
			restartButton.y = 500
			restartButton:toFront()

			utility.centreObjectX(menuButton)
			menuButton.y = 500
			menuButton:toFront()

			utility.centreObjectX(nextButton)
			nextButton:translate(150, 0)
			nextButton.y = 500
			nextButton:toFront()
		
		end

	end

	timer.performWithDelay(2900, closure)
end

t.trackWink = function(event) 

	if waitingToRestart == 0 and activeWink.x > activeWink.potLeft.x and activeWink.y > activeWink.yTarget and activeWink.x < activeWink.potRight.x and levelCompleted == false then 

		-- not waiting for restart and the active wink has reached the target
		print("wink in target")

		-- this was the last wink so move to the next level
		wink.name = "NOT IN USE"
		levelComplete()

	elseif (activeWink.x > (display.contentWidth - display.screenOriginX) or activeWink.y > activeWink.yLimit or activeWink.x < display.screenOriginX or activeWink.y < - 300) and waitingToRestart == 0 and levelCompleted == false then
		goneOutOfBounds()
    	end
end 

local function goToNextPressed(event)
	if "began" == event.phase then
		goToNext()
	end 
end

local function restart()
	transitionData.currentScene = currentScene
	transitionData.nextScene = currentScene
	storyboard.gotoScene("doNothingScene")  
end

-- Handler that gets notified when the alert closes
local function doRestart( event )
	if "began" == event.phase then
		restart() 
	end
end

-- Handler that gets notified when the alert closes
local function goToMenu( event )
	if "began" == event.phase then
		returnToMenu()
	end
end

local function isWinkStationary()
	linearVelocityX, linearVelocityY = activeWink:getLinearVelocity()
	local isStationary = (linearVelocityX < 0.01 and linearVelocityY < 0.01 and linearVelocityX > -0.01 and linearVelocityY > -0.01)
	return isStationary
end

local function getSpeed(startY, endY)
	print("startY is:" .. startY .. " and endY is:" .. endY)
	local distance = endY - startY

	print("Uncapped distance is " .. distance)

	if distance < 0 then
		distance = 0
	end

	print("capped distance is " .. distance)


	local speed = distance * 8
	speedText.text = string.sub(speed, 1, 6) .. " mm/s"
	speedText.alpha = 1

	return speed
end

t.drag = function( event )    
	local phase = event.phase  

	if "began" == phase then  
		print("swipe detected")
		swiper.y = event.y - 100

		if (swiper.y < 30) then
			swiper.y = 30
		end

		previousY = swiper.y

	else 
        	if "moved" == phase then  
			swiper.y = event.y - 100

			if (swiper.y < 30) then
				swiper.y = 30
			end

			if (previousY > swiper.y and swiper.y <= 275 and swiper.y > 29) then
				-- moving up inside the angle zone
				angleText.text = string.sub(angle, 1, 4) .. "º"
				angleText.alpha = 1
				angle = 90 * (previousY - 30) / 245
				dragStartY = previousY
			elseif angle ~= 180 and dragStartY ~= 0 then
				getSpeed(dragStartY, swiper.y)
				angleText.alpha = 1
			end

			previousY = swiper.y
        	elseif "ended" == phase or "cancelled" == phase then
			print("swipe ended")

			if angle ~= 180 then
				local maxSpeed = getSpeed(dragStartY, event.y - 100)
				print(dragStartY)
				print(angle)
				print(maxSpeed)

				local xProportion = math.cos(angle/57.3)
				local yProportion = math.sin(angle/57.3)

				print("Using drag multiplier " .. dragMultiplier)
				print(xProportion)
				print(yProportion)

	    			local xVelocity = maxSpeed * xProportion * dragMultiplier
	    			local yVelocity = maxSpeed * yProportion * -dragMultiplier
    	    			activeWink:setLinearVelocity(xVelocity , yVelocity) 
				print("setting wink speed as x: " .. xVelocity .. " y: " .. yVelocity)
	    			activeWink.angularVelocity = maxSpeed * -1
	    			maxSpeed = 0
				dragStartY = 0
				numFlicks = numFlicks + 1
				angle = 180
				utility.playSound(boing)
			end
        	end  
    	end  

    	return true  
end  

local function addWinkLocal(wink, colour, xLowerTarget, xUpperTarget, screenGroup, setAsActive, useBigPot)
	print("adding a wink")

	physics.addBody(wink, "dynamic", dynamicMaterial)
	screenGroup:insert(wink)

	wink.colour = colour
	wink.yTarget = 620
	wink.yLimit = 640

	if useBigPot then
		print("big pot")
		potFront = utility.loadImage("bigPotFront.png") 
		potFront:translate(xLowerTarget - 90, 590)
		potBack = utility.loadImage("bigPotBack.png") 
		potBack:translate(xLowerTarget - 87, 567)
		potLeft = display.newRect(xLowerTarget - 80, 590, 1, 500) 

	else
		potBack = utility.loadImage("potBack.png")
		potBack:translate(xLowerTarget - 1, 580)
		potFront = utility.loadImage("potFront.png")
		potFront:translate(xLowerTarget - 4, 590)
		potLeft = display.newRect(xLowerTarget, 590, 1, 500) 

	end

	potRight = display.newRect(xUpperTarget - 1, 590, 1, 500) 

	potLeft.alpha = 0
	potRight.alpha = 0 

	utility.addNewStaticObject(potLeft, 0,0,0, screenGroup)
	utility.addNewStaticObject(potRight, 0,0,0, screenGroup)

	screenGroup:insert(potFront)
	screenGroup:insert(potBack)

	wink.potLeft = potLeft
	wink.potRight = potRight
	wink.name = "wink"

	if setAsActive == "yes" then
		activeWink = wink
	end

	potBack:toFront()
	wink:toFront()
	potFront:toFront()
end

t.addWink = function(wink, colour, xLowerTarget, xUpperTarget, screenGroup, nextWink, setAsActive)
	addWinkLocal(wink, colour, xLowerTarget, xUpperTarget, screenGroup, setAsActive)
	wink.nextWink = nextWink
end

local function createGenericOverlay(screenGroup)
	print("creating overlay")

	overlayObjects = {}

	-- add the restart and menu buttons
	restartButton = utility.loadImage("restartButton.png")
	restartButton:translate(display.screenOriginX + 20, display.screenOriginY + 20)  
	screenGroup:insert(restartButton)

	menuButton = utility.addMenuButton(screenGroup, display.screenOriginX + 135, display.screenOriginY + 20)

	if transitionData.isLeftHanded then
		restartButton.x = display.contentWidth - display.screenOriginX - 235
		menuButton.x = display.contentWidth - display.screenOriginX - 120
	end

	table.insert(overlayObjects, restartButton)
	table.insert(overlayObjects, menuButton)
	table.insert(overlayObjects, staticWink)
end

-- what to do when the screen loads
t.createSceneCommon  = function(screenGroup, floorLength, thisScene, notUsed, storyB, useBigPot)
	print("creating scene objects")

	utility.playSoundWithOptions(backgroundNoise, {loops=-1})
	resetLevel()
	helpText = display.newText("", 0, 350, "GoodDog", 50)
	helpText2 = display.newText("", 0, 400, "GoodDog", 50)

	-- store off the storyboard info
	currentScene = "levels." .. thisScene

	levelIndex = utility.getLevelIndex(thisScene)
	completedScene = utility.getLevelName(levelIndex + 1)

	flicksPerStar.two = levelMappings[levelIndex][3]
	flicksPerStar.three = levelMappings[levelIndex][2]

	storyboard = storyB
	screenGp = screenGroup

	-- add the objects to this view

	-- background and floor
	print("adding normal background")
	background = utility.addBackground(screenGroup)
	local floor = utility.addFloor(screenGroup, floorLength)

	-- picture of the wink to swipe
	staticWink = utility.addStaticWink(screenGroup, transitionData.isLeftHanded)
	staticWink.isVisible = false
	staticWink.alpha = 0.8

	-- default wink (we always need one)
	wink = utility.loadImage("orangeWink.png")  
	wink:translate(50, 400) 
	addWinkLocal(wink, "orange", 880, 955, screenGroup, "yes", useBigPot)

	-- swiping area

	swiper = utility.loadImage("circle200.png")
	screenGroup:insert(swiper)
	swiper:setReferencePoint(display.TopCenterReferencePoint)
	swiper.alpha = 0.5
	swiper.isVisible = false

	angleText = utility.addBlackCentredText("", 25, screenGroup, 60)
	speedText = utility.addBlackCentredText("", 75, screenGroup, 60)

	if transitionData.isLeftHanded then
		angleText:translate(30, 0)
		speedText:translate(30, 0)
		swiper:translate(display.screenOriginX + 100, display.screenOriginY + 370) 
	else
		swiper:translate(display.contentWidth - display.screenOriginX - 290, display.screenOriginY + 370) 
	end

	-- set the default wink as the active one
	activeWink = wink

	outOfBoundsText = display.newText("", display.contentWidth + 10 - display.screenOriginX, 50, "GoodDog", 75)
	outOfBoundsText:setReferencePoint(display.TopCenterReferencePoint)
	outOfBoundsText:setTextColor(0,0,0)
	screenGroup:insert(outOfBoundsText)

	levelText = display.newText("LEVEL " .. levelIndex, 0, 0, "GoodDog", 100)
	utility.centreObjectX(levelText)
	levelText.y = 250
	levelText:setTextColor(0,0,0)
	screenGroup:insert(levelText)

	movingPlatformsX = {}
	movingPlatformsY = {}
	conveyerBelts = {}
	cans = {}
	clouds = {}
	wasps = {}
	flowers = {}
	ants = {}

	nextButton = utility.loadImage("nextButton.png")
	screenGroup:insert(nextButton)
	nextButton.isVisible = false

	createGenericOverlay(screenGroup)
end

local function fadeLevelText(event)
	if levelText.alpha > 0 then
		levelText:toFront()
		levelText.alpha = levelText.alpha - 0.01
	else
		Runtime:removeEventListener( "enterFrame", fadeLevelText )
	end
end

local function startStickyness(platform, event) 

	platform.stuck = 1

	if platform.removeObject then
		print("removing cover object")
		platform.removeObject:removeSelf()
		platform.removeObject = nil	
		utility.playSound(openCover)
	end
end  

local function moveToWhirlpool(initialWhirlPool, hitByWink) 
	print("moving wink to whirlpool")

	hitByWink:setLinearVelocity(0, 0)
	hitByWink.angularVelocity = 0
	hitByWink.x = initialWhirlPool.otherWhirlpool.x
	hitByWink.y = initialWhirlPool.otherWhirlpool.y + 5
end    

local function hitHoopTarget(target)
	target.exitCover:removeSelf()
	target:removeSelf()
	utility.playSound(openCover)
end

t.onLocalCollision = function(event)
        if event.phase == "began" then
		print("collision detected")

		if event.object1.name == "wink" or event.object2.name == "wink" then
			utility.playSound(clinkSound)
		end

		if event.object1.name == "can" or event.object2.name == "can" then
			utility.playSound(metal)
		end

		if (event.object1.name == "wink" and event.object2.otherName == "cobweb") or (event.object1.otherName == "cobweb" and event.object2.name == "wink") then
			utility.playSound(boing)
		end

		if event.object1.name == "staticPlatform" and event.object2.name == "wink" then
			print("collision with platform")

			local closure = function() return startStickyness(event.object1, event) end
			timer.performWithDelay(1, closure, 1)
		elseif event.object2.name == "staticPlatform" and event.object1.name == "wink" then			
			print("collision with platform")

			local closure = function() return startStickyness(event.object2, event) end
			timer.performWithDelay(1, closure, 1)
		end

        	if event.object1.name == "whirlpool" and event.object2.name == "wink" then
			utility.playSound(teleport)
			print("collision with flower")
			local closure = function() return moveToWhirlpool(event.object1, event.object2) end
			timer.performWithDelay( 1, closure, 1 )
        	elseif event.object2.name == "whirlpool" and event.object1.name == "wink" then
			utility.playSound(teleport)
			print("collision with flower")

			local closure = function() return moveToWhirlpool(event.object2, event.object1) end
			timer.performWithDelay( 1, closure, 1 )
		end

        	if event.object1.name == "hoopTarget" and event.object2.name == "wink" then
			print("collision with hoop target")
			local closure = function() return hitHoopTarget(event.object1) end
			timer.performWithDelay( 1, closure, 1 )
        	elseif event.object2.name == "hoopTarget" and event.object1.name == "wink" then
			print("collision with hoop target")

			local closure = function() return hitHoopTarget(event.object2) end
			timer.performWithDelay( 1, closure, 1 )
		end

        	if (event.object1.name == "wasp" and event.object2.name == "wink") or (event.object2.name == "wasp" and event.object1.name == "wink") then
			print("collision with wasp")
			timer.performWithDelay( 1, hitWasp, 1 )
		end

        	if (event.object1.name == "bolt" and event.object2.name == "wink") or (event.object2.name == "bolt" and event.object1.name == "wink") then
			print("collision with bolt")
			timer.performWithDelay( 1, hitBolt)
		end
        end
end

local function movePlatforms(event)  

    for i=1,#movingPlatformsX do

	local platform = movingPlatformsX[i]

	if platform.x <= platform.lowerLimit then
		platform.x = platform.lowerLimit + 1
		platform.direction = 1
	elseif platform.x >= platform.upperLimit then
		platform.x = platform.upperLimit - 1
		platform.direction = -1
	else 
		platform:translate(platform.direction * (platform.speed / 2), 0)
	end

	if platform.stuck == 1 then
		local isStationary = isWinkStationary()

		if isStationary then
			print("platform is stuck properly")
			platform.stuck = 2
		end 
	elseif platform.stuck == 2 then
		local isStationary = isWinkStationary()

		if (isStationary == false) then
			print("platform is unstuck")
			platform.stuck = 0 
		else 
			activeWink.x = activeWink.x + (platform.direction * (platform.speed / 2))
		end
	end

	platform.platformBottom.x = platform.x
	
	if platform.coverPic then
		platform.coverPic.x = platform.x
	end
    end

    for i=1,#movingPlatformsY do

	local platform = movingPlatformsY[i]

	if platform.y <= platform.lowerLimit then
		platform.y = platform.lowerLimit + 1
		platform.direction = 1
	elseif platform.y >= platform.upperLimit then
		platform.y = platform.upperLimit - 1
		platform.direction = -1
	else 
		platform.y = platform.y + (platform.direction * (platform.speed / 2))
	end

	if platform.stuck == 1 then

		local isStationary = isWinkStationary()

		if isStationary then
			activeWink.y = platform.y - 6
			platform.stuck = 2
		end 
	elseif platform.stuck == 2 then
		local isStationary = isWinkStationary()

		if (isStationary == false) then
			platform.stuck = 0 
		else 
			activeWink.y = platform.y - 6
		end
	end

	platform.platformBottom.y = platform.y + 5

	if platform.coverPic then
		platform.coverPic.y = platform.y + platform.yOffset
	end
    end

    	for i=1,#conveyerBelts do
		local platform = conveyerBelts[i]

		if platform.stuck == 1 then

			local isStationary = isWinkStationary()

			if isStationary then
				platform.stuck = 2
			end 
		elseif platform.stuck == 2 then
			local isStationary = isWinkStationary()

			if isStationary == false or activeWink.y > platform.y then
				platform.stuck = 0 
				--audio.stop()
			else 
				activeWink.x = activeWink.x + (platform.direction * (platform.speed / 2))
			end
		end
	end

end   

local function checkClouds(event)
	for i=1,#clouds do
		local cloudPlatform = clouds[i]
		if cloudPlatform ~= nil then
			if cloudPlatform.startSticky == nil and cloudPlatform.stuck == 1 then
				cloudPlatform.startSticky = event.time
				print("starting cloud timer")

			elseif cloudPlatform.startSticky ~= nil and cloudPlatform.startSticky < (event.time - 2250) then	
				cloudPlatform.coverPic.y = cloudPlatform.coverPic.y + 7
				cloudPlatform.platformBottom.y = cloudPlatform.platformBottom.y + 7
				cloudPlatform.y = cloudPlatform.y + 7

				if (cloudPlatform.y > (display.contentHeight - display.screenOriginY + 30)) then
					table.remove(clouds, i)

					if #clouds == 0 then
						Runtime:removeEventListener( "enterFrame", checkClouds )	
					end
				end
			end
		end
	end
end

local function checkCans(event)
	for i=1,#cans do
		local can = cans[i]
		
		if can.y > can.targetY and can.exitCover ~= nil then
			print("removing can cover")
			can.exitCover:removeSelf()
			utility.playSound(openCover)
			table.remove(cans, i)

			if #cans == 0 then
				Runtime:removeEventListener( "enterFrame", checkCans )	
			end
		end
	end
end

local function moveWasps(event)
	for i=1,#wasps do
		local wasp = wasps[i]

		if i == 1 then
			local lastBuzz = wasp.lastBuzz

			if lastBuzz == nil then
				wasp.lastBuzz = event.time
			else
				local rand = math.random(7)
				
				if rand > 5 and (lastBuzz + (rand * 100)) < event.time then
					wasp.lastBuzz = event.time
					utility.playSound(buzz)
				end
			end 
		end

		wasp.x = wasp.x + wasp.xDirection
		wasp.y = wasp.y + wasp.yDirection

		local random = math.random(11)

		if ((wasp.x <= wasp.lowerBoundaryX) or (wasp.x >= wasp.upperBoundaryX) or (random > 10)) then
			wasp.xDirection = wasp.xDirection * -1
		end

		if ((wasp.y <= wasp.lowerBoundaryY) or (wasp.y >= wasp.upperBoundaryY) or (random < 2)) then
			wasp.yDirection = wasp.yDirection * -1
		end
	end
end

local function showStaticWink(event)
	if (outOfBounds or levelCompleted) then
		staticWink.isVisible = false
		swiper.isVisible = false
	else

		local isStationary = isWinkStationary()

		if (isStationary and staticWink.isVisible == false) then
			staticWink.isVisible = true
			swiper.isVisible = true
			swiper.y = display.screenOriginY + 370
			swiper:toFront()
		elseif (isStationary == false and staticWink.isVisible) then
			staticWink.isVisible = false
			swiper.isVisible = false
		end
	end
end

local function moveAnts()
	for i=1,#ants do
		local ant = ants[i]
		ant.x = ant.x + (ant.direction / 2)

		if ant.direction > 0 then
			if ant.x > ant.xLimit then
				ant.x = ant.startX
			end
		else
			if ant.x < ant.xLimit then
				ant.x = ant.startX
			end
		end
	end
end

t.addNewPlatform = function(platform, colour1, colour2, colour3, screenGroup, isBouncy)
	print("adding new platform")

	if isBouncy then
		utility.addNewBouncyObject(platform, colour1, colour2, colour3, screenGroup)
	else
		utility.addNewKinematicObject(platform, colour1, colour2, colour3, screenGroup)
	end

	platform.name = "staticPlatform" 
	platform.collision = t.onLocalCollision
end

t.addNewPlatformWithRemoveObject = function(platform, colour1, colour2, colour3, screenGroup, objectToRemove)
	print("adding new platform with remove object")
	t.addNewPlatform(platform, colour1, colour2, colour3, screenGroup) 
	platform.removeObject = objectToRemove
end

t.addNewCloud = function(cloud, platform, platformBottom, screenGroup, objectToRemove)
	print("adding new cloud")
	t.addNewPlatformWithRemoveObject(platform, 0, 0, 0, screenGroup, objectToRemove)
	platform.cloud = cloud
	platform.platformBottom = platformBottom
	table.insert(clouds, platform)
end

t.makePlatformMoveX = function(platform, xSpeed, lowerLimit, upperLimit)
	print("moving a platform in x direction")
	utility.makePlatformMove(platform, xSpeed, lowerLimit, upperLimit, movingPlatformsX)
end

t.makePlatformMoveY = function(platform, ySpeed, lowerLimit, upperLimit)
	print("moving a platform in y direction")
	utility.makePlatformMove(platform, ySpeed, lowerLimit, upperLimit, movingPlatformsY)
end

t.makePlatformConvey = function(platform, speed, direction, screenGroup)
	print("making a platform convey")
	utility.makePlatformConvey(platform, speed, direction, conveyerBelts)

	-- need to add ants onto the branch
	local width = platform.width
	local numAnts = math.round(width / 15)
	local startX = platform.x - (width / 2)
	local endX = platform.x + (width / 2)

	for i=1,numAnts do 
		local xPosition = startX + ((i - 1) * 15)
		print(xPosition)

		local ant = display.newRect(xPosition, platform.y - 5, 3, 3)
		ant:setFillColor(0,0,0)
		table.insert(ants, ant)
		screenGroup:insert(ant)
		ant.direction = direction

		if direction == 1 then
			ant.startX = startX
			ant.xLimit = endX
		else 
			ant.startX = endX
			ant.xLimit = startX
		end
	end

end

t.addNewWhirlpool = function(whirlpool, otherWhirlpool)
	print("adding a whirlpool")
	whirlpool.otherWhirlpool = otherWhirlpool
	whirlpool.name = "whirlpool"
	whirlpool.collision = onLocalCollision
end

t.createPlatform = function(xLocation, yLocation, coverY, coverColour, coverPic, screenGroup, platformLength)

	if platformLength == nil then
		platformLength = 120
	end

	print("creating a platform at " .. xLocation .. " " .. yLocation)

	exitCover = utility.addExitCover(screenGroup, coverColour, coverY)

	staticPlatformBottom = display.newRect(xLocation, yLocation + 5, platformLength, 5) 
	utility.addNewStaticObject(staticPlatformBottom, 0,0,0, screenGroup) 

	staticPlatform = display.newRect(xLocation, yLocation, platformLength, 5) 
	t.addNewPlatformWithRemoveObject(staticPlatform, 0,0,0, screenGroup, exitCover) 

	staticPlatformBottom.alpha = 0
	staticPlatform.alpha = 0
	staticPlatform.coverPic = coverPic
	staticPlatform.platformBottom = staticPlatformBottom

	return staticPlatform
end

t.addLeaf = function(xLocation, yLocation, coverY, coverColour, screenGroup)
	print("adding leaf to screen at " .. xLocation .. " " .. yLocation)
	local leaf = utility.loadImage("newLeaf2.png")
	leaf:translate(xLocation, yLocation + 26)
	screenGroup:insert(leaf)
	local colour = {84, 163, 98}
	local platform = t.createPlatform(xLocation, yLocation + 28, coverY, colour, leaf, screenGroup)
	platform.yOffset = 28
	leaf:toBack()
	background:toBack()
	leaf.platform = platform
	return leaf
end

t.addCloud = function(xLocation, yLocation, coverY, coverColour, screenGroup)
	print("adding cloud to screen at " .. xLocation .. " " .. yLocation)
	local cloud = utility.loadImage("brownLeaf.png")
	cloud:translate(xLocation - 26, yLocation)
	screenGroup:insert(cloud)

	local colour = {202, 75, 56}
	local platform = t.createPlatform(xLocation, yLocation + 2, coverY, colour, cloud, screenGroup)
	table.insert(clouds, platform)
	cloud:toBack()
	background:toBack()
	return cloud
end

local function flashFlower(event) 
	for i=1, #flowers do
		flower = flowers[i]
		if event.time - flower.lastChange > 1000 and flower.isBlack == false then
			flower.lastChange = event.time
			flower:setFillColor(255,255,255)
			flower.isBlack = true
		elseif event.time - flower.lastChange > 100 and flower.isBlack then
			flower.lastChange = event.time
			flower:setFillColor(flower.startColour[1],flower.startColour[2],flower.startColour[3])
			flower.isBlack = false
		end
	end
end

t.addFlower = function(xLocation, yLocation, xLocation2, yLocation2, colour, screenGroup)
	print("adding flower to screen at " .. xLocation .. " " .. yLocation)

	local flower = utility.loadImage("flower2.png")
	flower:translate(xLocation, yLocation)
	screenGroup:insert(flower)

	local whirlpool1 = display.newCircle(xLocation + 47, yLocation + 49, 10)  
	utility.addNewKinematicObject(whirlpool1, colour[1], colour[2], colour[3], screenGroup) 
	whirlpool1.startColour = colour
	whirlpool1.lastChange = 0
	whirlpool1.isBlack = false

	local whirlpool2 = display.newCircle(xLocation2, yLocation2, 10)  
	whirlpool2:setFillColor(colour[1], colour[2], colour[3])
	screenGroup:insert(whirlpool2) 
	whirlpool2.startColour = colour
	whirlpool2.lastChange = 0
	whirlpool2.isBlack = false

	t.addNewWhirlpool(whirlpool1, whirlpool2)

	flower:toBack()
	background:toBack()
	table.insert(flowers, whirlpool1)
	table.insert(flowers, whirlpool2)

	Runtime:addEventListener("enterFrame", flashFlower)
	return flower
end

t.addHoop = function(xLocation, yLocation, coverY, colour, screenGroup)
	print("adding hoop to screen at " .. xLocation .. " " .. yLocation)

	local stand = utility.addWood(xLocation, yLocation + 80, screenGroup)
	local apple = utility.loadImage("apple.png")
	apple:translate(xLocation, yLocation - 18)
	screenGroup:insert(apple)
	local blocker = display.newRect(xLocation, yLocation+12, 75, 1)
	blocker.alpha = 0
	utility.addNewStaticObject(blocker, 0,0,0, screenGroup) 

	local target = display.newRect(xLocation + 45, yLocation + 35, 10, 50)
	utility.addNewObject(target, 0, 0, 0, screenGroup) 
	physics.addBody(target, "dynamic", {density=0.000001, friction=.0003, bounce=.00003}) 
	target.alpha = 0

	local exitCover = utility.addExitCover(screenGroup, {255, 0, 0}, coverY)

	target.name = "hoopTarget" 
	target.collision = t.onLocalCollision
	target.exitCover = exitCover

end

t.addCanTargetExitCover = function(can, canTargetYLocation, yLocationForExit, screenGroup)
	print("adding can exit cover at " .. yLocationForExit)
	local exitCover = utility.addExitCover(screenGroup, {150, 150, 150}, yLocationForExit)
	can.targetY = canTargetYLocation
	can.exitCover = exitCover
	can.name = "can"
	table.insert(cans, can)
end

t.moveWasp = function(wasp, lowerBoundaryX, lowerBoundaryY, upperBoundaryX, upperBoundaryY)
	table.insert(wasps, wasp)
	wasp.lowerBoundaryY = lowerBoundaryY
	wasp.lowerBoundaryX = lowerBoundaryX
	wasp.upperBoundaryY = upperBoundaryY
	wasp.upperBoundaryX = upperBoundaryX
	wasp.xDirection = 3
	wasp.yDirection = 3
	wasp.name = "wasp"
end

local function createSimplePlatform(xLocation, yLocation, coverPic, screenGroup, platformLength, isBouncy)

	if platformLength == nil then
		platformLength = 120
	end

	print("creating a simple platform")

	staticPlatformBottom = display.newRect(xLocation, yLocation + 5, platformLength, 5) 
	utility.addNewStaticObject(staticPlatformBottom, 0,0,0, screenGroup) 

	staticPlatform = display.newRect(xLocation, yLocation, platformLength, 5) 
	t.addNewPlatform(staticPlatform, 0,0,0, screenGroup, isBouncy) 

	staticPlatformBottom.alpha = 0
	staticPlatform.alpha = 0
	staticPlatform.coverPic = coverPic
	staticPlatform.platformBottom = staticPlatformBottom

	return staticPlatform
end

local function addConveyer(conveyerImage, screenGroup, xLocation, yLocation, direction, platformLength)

	local shiftMultiplier = platformLength / 200
	print("adding conveyer to screen at " .. xLocation .. " " .. yLocation)
	conveyerImage:translate(xLocation - (platformLength / 5), yLocation - 32)
	screenGroup:insert(conveyerImage)
	local platform = createSimplePlatform(xLocation, yLocation, conveyerImage, screenGroup, platformLength)
	conveyerImage:toBack()
	background:toBack()

	t.makePlatformConvey(platform, 3, direction, screenGroup)

	return conveyerImage
end

t.addShortConveyer = function(screenGroup, xLocation, yLocation, direction)
	local conveyerImage = utility.loadImage("shortBranch2.png")
	local conveyer = addConveyer(conveyerImage, screenGroup, xLocation, yLocation, direction, 200)
	return conveyer
end

t.addLongConveyer = function(screenGroup, xLocation, yLocation, direction)
	local conveyerImage = utility.loadImage("longBranch2.png")
	local conveyer = addConveyer(conveyerImage, screenGroup, xLocation, yLocation, direction, 400)
	return conveyer
end

t.addCobweb = function(screenGroup, xLocation, yLocation, coverY)
	print("adding cobweb to " .. xLocation .. " " .. yLocation)
	local cobweb = utility.loadImage("cobweb.png")
	cobweb:translate(xLocation, yLocation)
	screenGroup:insert(cobweb)
	local platform = createSimplePlatform(xLocation, yLocation + 20, cobweb, screenGroup, 150, true)
	local colour = {150, 150, 150}
	platform.otherName = "cobweb"

	local exitCover = utility.addExitCover(screenGroup, colour, coverY) 

	platform.removeObject = exitCover
	cobweb:toBack()
	background:toBack()
end

-- add all the event listening
t.enterSceneCommon = function()
	print("entering scene common")
	storyboard.purgeScene(transitionData.currentScene)
	transitionData.currentScene = currentScene 
	Runtime:addEventListener("enterFrame", fadeHelpText )
	Runtime:addEventListener("enterFrame", t.trackWink)  
	swiper:addEventListener("touch", t.drag) 
	restartButton:addEventListener("touch", doRestart) 
	menuButton:addEventListener("touch", goToMenu) 
	nextButton:addEventListener("touch", goToNextPressed)

	if #movingPlatformsX ~= 0 or #movingPlatformsY ~= 0 or #conveyerBelts ~= 0 then
		Runtime:addEventListener("enterFrame", movePlatforms)
	end

	Runtime:addEventListener( "collision", t.onLocalCollision )

	if #clouds > 0 then
		Runtime:addEventListener( "enterFrame", checkClouds )
	end

	if #cans > 0 then
		Runtime:addEventListener( "enterFrame", checkCans )
	end

	if #wasps > 0 then
		Runtime:addEventListener( "enterFrame", moveWasps )
	end

	if #ants > 0 then
		Runtime:addEventListener( "enterFrame", moveAnts )
	end

	Runtime:addEventListener( "enterFrame", showStaticWink )
	Runtime:addEventListener( "enterFrame", fadeLevelText )

	for i=1,#overlayObjects do
		local overlay = overlayObjects[i]
		overlay:toFront()
	end

	Runtime:addEventListener("enterFrame", fadeSpeedAndAngleText)

end

t.exitSceneCommon = function()
	print("exiting scene common")
	Runtime:removeEventListener("enterFrame", t.trackWink) 
	swiper:removeEventListener("touch", t.drag) 
	restartButton:removeEventListener("touch", doRestart)
	menuButton:removeEventListener("touch", goToMenu)

	Runtime:removeEventListener("enterFrame", movePlatforms)

	Runtime:removeEventListener( "collision", t.onLocalCollision )

	Runtime:removeEventListener( "enterFrame", checkClouds )
	Runtime:removeEventListener( "enterFrame", checkCans )

	Runtime:removeEventListener( "enterFrame", moveWasps )

	Runtime:removeEventListener( "enterFrame", showStaticWink )

	Runtime:removeEventListener( "enterFrame", moveAnts )

	Runtime:removeEventListener( "enterFrame", fadeLevelText )

	Runtime:removeEventListener("enterFrame", flashFlower)
	Runtime:removeEventListener("enterFrame", moveOutOfBoundsText)
	Runtime:removeEventListener("enterFrame", fadeHelpText )
	Runtime:removeEventListener( "enterFrame", fadeSpeedAndAngleText )
	nextButton:removeEventListener("touch", goToNextPressed)

end

return t

