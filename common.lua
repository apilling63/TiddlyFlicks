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
local facebook = require "facebook"
local levelMappings = require "levelMappings"
local json = require("json")

local t = {}
local transitionData = require "sceneTransitionData"

local dragStartY = 0  
local dragStartTime = 0  
local speedLimit = 3000
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
local trainingButton
local numStars
local levelIndex
local staticStart = 20
local staticEnd = 320

local helpText
local helpText2

local function fadeHelpText(event)
	if helpText and helpText.alpha > 0 then
		helpText:toFront()
		helpText.alpha = helpText.alpha - 0.002
	end

	if helpText2 and helpText2.alpha > 0 then
		helpText2:toFront()
		helpText2.alpha = helpText2.alpha - 0.002
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

local function moveFinger(event)
	local finger = staticWink.finger

	if finger.isVisible then
		if finger.y < 470 then
			finger.y = finger.y + 4
		else
			finger.y = 220
		end
	end
end

local function resetLevel() 
	-- reset level values
	--doDecrement = true
	outOfBounds = false
	levelCompleted = false

	waitingToRestart = 0
	windSpeed = 0
	numFlicks = 0

	-- reset gravity
	physics.setGravity(0, 9.81)

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

local function levelChangeCommon()
	background:toFront()
	background.alpha = 0.9
	outOfBoundsText:toFront()
	--outOfBoundsText:setTextColor(0,0,0)

	for i=1,#clouds do
		table.remove(clouds, i)
	end

	for i=1,#cans do
		table.remove(cans, i)
	end

	for i=1,#wasps do
		table.remove(wasps, i)
	end

	for i=1,#ants do
		table.remove(ants, i)
	end

	for i=1,#movingPlatformsX do
		table.remove(movingPlatformsX, i)
	end

	for i=1,#movingPlatformsY do
		table.remove(movingPlatformsY, i)
	end

	for i=1,#conveyerBelts do
		table.remove(conveyerBelts, i)
	end
end

local function returnToMenu()
	print("return to menu")
	transitionData.currentScene = currentScene
	transitionData.nextScene = "menu1"
	storyboard.gotoScene("menu1") 
end

local function fblistener( event )
    if ( "session" == event.type ) then
        -- upon successful login, post the message
        if ( "login" == event.phase ) then
                        local attachment = {
                                name = "Come and play Tiddly Flicks too!",
                                link = "http://www.appappnaway.co.uk/tiddly-flicks",
                                description = "What do you get if you cross a retro platform video game with a classic board game?  TIDDLY FLICKS!",
                                picture = "http://www.appappnaway.co.uk/images/tiddly-icon.png",
                                message = "Tiddly Flicks - play it now on Android, iPhone and iPad"
                        }
                
		facebook.request( "me/feed", "POST", attachment )
        end
    elseif ( "request" == event.type ) then
        -- event.response is a JSON object from the FB server
        local response = event.response
        print( response )
    end
end



local function unlock1(event)
	if "clicked" == event.action then

        	local i = event.index

	        if 1 == i then
			local closure1 = function()
				storyboard.gotoScene(transitionData.nextScene) 
			end

			local closure = function()
				training.purchase(1, closure1)
			end
			
			timer.performWithDelay(10, closure)
		else
			returnToMenu()
		end
	end
end

local function confirmContactFaceBook(event)
	if "clicked" == event.action then

        	local i = event.index

	        if 1 == i then
			-- first argument is the app id that you get from Facebook
			facebook.login( "151025625078894", fblistener, {"publish_stream"} )
		end

		storyboard.gotoScene(transitionData.nextScene)
	end
end

local function goToTraining(event)
	if "began" == event.phase then
		transitionData.currentScene = currentScene
		transitionData.nextScene = "trainingScene"
		storyboard.gotoScene("trainingScene")  
	end
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

local function hitHazard(text)
	if waitingToRestart == 0 then
		activeWink.isVisible = false
		activeWink.name = "donotuse"
		utility.playSound(ouch)
		waitingToRestart = 1 
		print("hit hazard")
		outOfBounds = true

		outOfBoundsText.text = text
		levelChangeCommon()

		Runtime:addEventListener("enterFrame", moveOutOfBoundsText)
	end
end

local function hitWasp()
	hitHazard("TIDDLY GOT STUNG!!")
end

local function hitBolt()
	hitHazard("TIDDLY GOT SHOCKED!!")
end

local function goneOutOfBounds()
	utility.playSound(ohNo)
	waitingToRestart = 1 
	print("wink out of bounds")
	outOfBounds = true
	outOfBoundsText.text = "OUT OF BOUNDS!!"
	levelChangeCommon()
	Runtime:addEventListener("enterFrame", moveOutOfBoundsText)
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

local function promptFacebook()

	if levelIndex == 32 and utility.hasUnlocked1() == false then
		utility.playSound(applause)
		native.showAlert( "TIDDLY MASTER!!", "Congratulations upon completing the first 32 levels of Tiddly Flicks Escape from the Country - you're a true Tiddly Master! Continue the fun by unlocking some more levels", { "Unlock", "Maybe later" }, unlock1 )
	else
		local random = math.random(3)

		print("random number is " .. random)

		if random > 1 then
			storyboard.gotoScene(transitionData.nextScene) 
		else 
			native.showAlert( "Facebook", "Post your progress on Facebook!", { "Sure!", "No thanks" }, confirmContactFaceBook )
		end
	end
end

local function levelComplete()
	utility.playSound(yes)
	utility.playSound(applause)

	outOfBoundsText.text = "A TIDDLY TRIUMPH!!"
	levelChangeCommon()

	transitionData.currentScene = currentScene 
	transitionData.nextScene = completedScene 
	
	menuButton.isVisible = false
	restartButton.isVisible = false

	levelCompleted = true
	Runtime:addEventListener("enterFrame", moveOutOfBoundsText)

	if numFlicks <= flicksPerStar.three then
		numStars = 3
	elseif numFlicks <= flicksPerStar.two then
		numStars = 2
	else
		numStars = 1
	end

	insertStars()

	-- always start a new level unsimplified
	transitionData.isLevelSimplified = false

	timer.performWithDelay(2000, addStarOne)
	timer.performWithDelay(2300, addStarTwo)
	timer.performWithDelay(2600, addStarThree)

	local closure = function()
		local goToNextText = display.newText("Have a go at the next level!", 0, 350, "GoodDog", 60)
		utility.centreObjectX(goToNextText)
		screenGp:insert(goToNextText)
		utility.playSound(ding)

	end

	timer.performWithDelay(2900, closure)

	timer.performWithDelay(4000, promptFacebook)
end

t.trackWink = function(event) 

	if waitingToRestart == 0 and activeWink.x > activeWink.potLeft.x and activeWink.y > activeWink.yTarget and activeWink.x < activeWink.potRight.x and levelCompleted == false then 

		-- not waiting for restart and the active wink has reached the target
		print("wink in target")

		if activeWink.nextWink then

			-- there is another wink that has not found the target yet
			print("still another wink")

			activeWink = activeWink.nextWink
			local colour = utility.getColour(activeWink.colour)
			--staticWink:setFillColor(colour[1], colour[2], colour[3])

		else
			print("level complete")
			-- this was the last wink so move to the next level
			wink.name = "NOT IN USE"
			levelComplete()
		end

	elseif (activeWink.x > (display.contentWidth - display.screenOriginX) or activeWink.y > activeWink.yLimit or activeWink.x < display.screenOriginX or activeWink.y < - 300) and waitingToRestart == 0 and levelCompleted == false then
		goneOutOfBounds()
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

t.drag = function( event )    
	local phase = event.phase  

	if "began" == phase then  
		print("swipe detected")

		-- only want a swipe to effect a change if the active wink is stationary
		local isStationary = isWinkStationary()

		if (isStationary and event.y < 290 and event.y > 20) then
			print("valid swipe")

        		-- Store initial position  
        		dragStartY = event.y
			dragStartTime = event.time
		end
	elseif dragStartY ~= 0 then 
        	if "moved" == phase then  
			-- just set the current position
            		currentY = event.y

        	elseif "ended" == phase or "cancelled" == phase then
			print("swipe ended")
			local isStationary = isWinkStationary()

			-- check the wink isn't moving then make it move!
			if isStationary then
				local distance = event.y - dragStartY
				local time = event.time - dragStartTime
				local maxSpeed = distance * 1000 / time
				local angle = 90 * (dragStartY - 20) / 270
				print(dragStartY)
				print(angle)
				print(maxSpeed)

				local xProportion = math.cos(angle/57.3)
				local yProportion = math.sin(angle/57.3)

				print(xProportion)
						print(yProportion)


	    			local xVelocity = maxSpeed * xProportion * 0.5
	    			local yVelocity = maxSpeed * yProportion * -0.5
    	    			activeWink:setLinearVelocity(xVelocity , yVelocity) 
				print("setting wink speed as x: " .. xVelocity .. " y: " .. yVelocity)
	    			activeWink.angularVelocity = maxSpeed * -1
	    			maxSpeed = 0
				dragStartY = 0
				numFlicks = numFlicks + 1
				utility.playSound(boing)
			end
        	end  
    	end  

    	return true  
end  

local function addDynamicObject(object, screenGroup)
	physics.addBody(object, "dynamic", dynamicMaterial)
	screenGroup:insert(object)
end

local function addWinkLocal(wink, colour, xLowerTarget, xUpperTarget, screenGroup, setAsActive, useBigPot)
	print("adding a wink")

	addDynamicObject(wink, screenGroup)

	local potColour = utility.getColour(colour)

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

	-- default wink (we always need one)
	wink = utility.loadImage("orangeWink.png")  
	wink:translate(50, 400) 
	addWinkLocal(wink, "orange", 880, 955, screenGroup, "yes", useBigPot)

	-- swiping area

	if transitionData.isLeftHanded then
		swiper = display.newRect(display.screenOriginX + 92, display.screenOriginY + 20, 200, 640 - display.screenOriginY) 
	else
		swiper = display.newRect(display.contentWidth - display.screenOriginX - 292, display.screenOriginY + 20, 200, 640 - display.screenOriginY) 
	end

	swiper:setFillColor(33, 33, 33)  
	swiper.alpha = 0.01
	screenGroup:insert(swiper)

	local finger = utility.loadImage("finger.png") 
	finger:translate(staticWink.x - 75, 220)
	screenGroup:insert(finger)
	fingerSpeed = 4
	finger.isVisible = false
	staticWink.finger = finger

	-- set the default wink as the active one
	activeWink = wink

	windIndicators = {}

	local windIndicator1 = display.newRect(200, 400, 20, 2)
	windIndicator1.isVisible = false
	table.insert(windIndicators, windIndicator1)
	screenGroup:insert(windIndicator1)

	local windIndicator2 = display.newRect(470, 200, 20, 2)
	windIndicator2.isVisible = false
	table.insert(windIndicators, windIndicator2)
	screenGroup:insert(windIndicator2)

	local windIndicator3 = display.newRect(915, 300, 20, 2)
	windIndicator3.isVisible = false
	table.insert(windIndicators, windIndicator3)
	screenGroup:insert(windIndicator3)

	outOfBoundsText = display.newText("", display.contentWidth + 10 - display.screenOriginX, 50, "GoodDog", 75)
	outOfBoundsText:setReferencePoint(display.TopCenterReferencePoint)
	outOfBoundsText:setTextColor(0,0,0)
	screenGroup:insert(outOfBoundsText)

	levelText = display.newText("LEVEL " .. levelIndex, 0, 0, "GoodDog", 100)
	utility.centreObjectX(levelText)
	levelText.y = 250
	levelText:setTextColor(0,0,0)
	screenGroup:insert(levelText)

	trainingButton = utility.loadImage("training.png")
	utility.centreObjectX(trainingButton)
	trainingButton.y = 1000
	screenGp:insert(trainingButton)

	movingPlatformsX = {}
	movingPlatformsY = {}
	conveyerBelts = {}
	cans = {}
	clouds = {}
	wasps = {}
	flowers = {}
	ants = {}

	buttonsOn = false

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

local function applyWindForce(event)
	if windSpeed ~= 0 then
		for i=1,#windIndicators do
			local windIndicator = windIndicators[i]
			if windIndicator.x > 1200 then
				windIndicator.x = -200
			elseif windIndicator.x < -200 then
				windIndicator.x = 1200
			end

			windIndicator.x = windIndicator.x + (windSpeed * 100)
			activeWink:applyForce(windSpeed, 0, wink.x, wink.y )
		end
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

			elseif cloudPlatform.startSticky ~= nil and cloudPlatform.startSticky < (event.time - 1300) then	
				cloudPlatform.coverPic.y = cloudPlatform.coverPic.y + 5
				cloudPlatform.platformBottom.y = cloudPlatform.platformBottom.y + 5
				cloudPlatform.y = cloudPlatform.y + 5

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

		if staticWink.finger then
			staticWink.finger.isVisible = false
		end
	else

	local isStationary = isWinkStationary()

	if (isStationary and staticWink.isVisible == false) then
		staticWink.isVisible = true

		if staticWink.finger then
			staticWink.finger.isVisible = true
			staticWink.finger:toFront()
		end
	elseif (isStationary == false and staticWink.isVisible) then
		staticWink.isVisible = false

		if staticWink.finger then
			staticWink.finger.isVisible = false
		end
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

	if windSpeed ~= 0 then
		Runtime:addEventListener( "enterFrame", applyWindForce )
	end

	Runtime:addEventListener( "enterFrame", showStaticWink )
	Runtime:addEventListener( "enterFrame", fadeLevelText )
	Runtime:addEventListener( "enterFrame", moveFinger )

	for i=1,#overlayObjects do
		local overlay = overlayObjects[i]
		overlay:toFront()
	end

	trainingButton:addEventListener("touch", goToTraining)
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

	Runtime:removeEventListener( "enterFrame", applyWindForce )

	Runtime:removeEventListener( "enterFrame", moveWasps )

	Runtime:removeEventListener( "enterFrame", showStaticWink )

	Runtime:removeEventListener( "enterFrame", moveAnts )

	Runtime:removeEventListener( "enterFrame", fadeLevelText )

	trainingButton:removeEventListener("touch", goToTraining)
	Runtime:removeEventListener("enterFrame", flashFlower)
	Runtime:removeEventListener("enterFrame", moveOutOfBoundsText)
	Runtime:removeEventListener( "enterFrame", moveFinger )
	Runtime:removeEventListener("enterFrame", fadeHelpText )

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

t.setWindSpeed = function(speed)
	print("setting wind speed to " .. speed)

	for i=1,#windIndicators do
		windIndicators[i].isVisible = true
	end

	windSpeed = speed
	--windSpeedText.text = windSpeed * 100 .. " wind speed"
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

t.addFinger = function(yOffset, screenGroup)
	--local finger = utility.loadImage("finger.png") 
	--finger:translate(staticWink.x - 35, staticWink.y - yOffset)
	--screenGroup:insert(finger)
	--fingerSpeed = 4
	--fingerReset = finger.y
	--finger.isVisible = false
	--staticWink.finger = finger
	--finger.shown = false
end

return t

