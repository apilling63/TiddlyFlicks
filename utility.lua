-----------------------------------------------------------------------------------------
--
-- utility.lua
--
-----------------------------------------------------------------------------------------
local u = {}
local facebookSession = false
staticMaterial = {density=2, friction=.15, bounce=.4}
stickyMaterial = {density=2, friction=1, bounce=0.001}
bouncyMaterial = {density=2, friction=0.1, bounce=1.15}

dynamicMaterial = {density=.8, friction=.8, bounce=.01}
dynamicLightMaterial = {density=.1, friction=.3, bounce=.3}

local exitCoverShape = {-41,1, -41,-1, 41,-1, 41,1}
local exitCoverMaterial = {density=2, friction=.15, bounce=.4, shape=exitCoverShape}

local grassShape = {-508, 63, -508,-27, 508,-27, 508,63}
local grassMaterial = {density=2, friction=.15, bounce=.4, shape=grassShape}

local lightningShape = {-20, 340, -20,-343, 10,-343, 10,340}
local lightningMaterial = {density=2, friction=.15, bounce=.4, shape=lightningShape}

local gradient = graphics.newGradient({ 30, 144, 255 },
		  			{ 92, 172, 230 },
		  			"down" )
local persistent = require("persistent")
local levelMappings = require "levelMappings"
local transitionData = require "sceneTransitionData"
local facebook = require "facebook"

local starsStore = {}
local playSounds = true

function u.playSound(sound)
	if playSounds == true then
		audio.play(sound)
	end
end

function u.playSoundWithOptions(sound, options)
	if playSounds == true then
		audio.play(sound, options)
	end
end

function u.stopSound()
	if playSounds == true then
		print("stopping sounds")
		audio.stop()
	end
end

function u.getColour(colour)
	local ret = {33, 33, 33}

	if colour == "blue" then
		ret = {0, 0, 255}
	elseif colour == "red" then
		ret = {255, 0, 0}
	elseif colour == "orange" then
		ret = {255, 128, 0}
	elseif colour == "green" then
	end

	return ret
end

function u.addNewDynamicLightPicture(picture, screenGroup)
	physics.addBody(picture, "dynamic", dynamicLightMaterial) 
	screenGroup:insert(picture)
end

function u.addNewStaticPicture(picture, screenGroup)
	physics.addBody(picture, "static", staticMaterial) 
	screenGroup:insert(picture)

end

function u.addBodyToPhysics(picture)
	physics.addBody(picture, "static", staticMaterial) 
end

function u.removeBodyFromPhysics(picture)
	physics.removeBody(picture) 
end

function u.addNewObject(object, colour1, colour2, colour3, screenGroup) 
	object:setFillColor(colour1, colour2, colour3) 
	screenGroup:insert(object)
end   

function u.addNewStaticObject(object, colour1, colour2, colour3, screenGroup)
	u.addNewObject(object, colour1, colour2, colour3, screenGroup) 
	physics.addBody(object, "static", staticMaterial)  
end

function u.addNewKinematicObject(object, colour1, colour2, colour3, screenGroup)
	u.addNewObject(object, colour1, colour2, colour3, screenGroup) 
	print("adding sticky object")
	physics.addBody(object, "kinematic", stickyMaterial)  
end

function u.addNewBouncyObject(object, colour1, colour2, colour3, screenGroup)
	u.addNewObject(object, colour1, colour2, colour3, screenGroup) 
	print("adding bouncy object")
	physics.addBody(object, "kinematic", bouncyMaterial)  
end

function u.makePlatformMove(platform, speed, lowerLimit, upperLimit, tableToAdd)
	platform.stuck = 0
	platform.speed = speed
	platform.lowerLimit = lowerLimit
	platform.upperLimit = upperLimit
	platform.direction = 1
	table.insert(tableToAdd, platform)
end

function u.makePlatformConvey(platform, speed, direction, tableToAdd)
	u.makePlatformMove(platform, speed, 0, 0, tableToAdd)
	platform.direction = direction
end

function u.addHoopTarget(hoop, xTargetLow, xTargetHigh, yTargetLow, yTargetHigh, exitCover, tableToAdd)
	hoop.xTargetLow = xTargetLow
	hoop.xTargetHigh = xTargetHigh
	hoop.yTargetLow = yTargetLow
	hoop.yTargetHigh = yTargetHigh
	hoop.exitCover = exitCover
	table.insert(tableToAdd, hoop)
end


u.centreObjectX = function(object)
	object:setReferencePoint(display.TopCenterReferencePoint)
	object.x = 480
end

u.loadImage = function(name)
	image = display.newImage("images/" .. name, false) 
	return image
end

u.addWood = function(xLocation, yLocation, screenGroup)
	print("adding wood to screen at " .. xLocation .. " " .. yLocation)
	local wood = u.loadImage("wood2.png")
	wood:translate(xLocation, yLocation)
	u.addNewStaticPicture(wood, screenGroup)
	return wood
end

u.addWoodUpsideDown = function(xLocation, yLocation, screenGroup)
	print("adding wood u-d to screen at " .. xLocation .. " " .. yLocation)
	local wood = u.loadImage("woodUpsideDown.png")
	wood:translate(xLocation, yLocation)
	u.addNewStaticPicture(wood, screenGroup)
	return wood
end

u.addBolt = function(xLocation, screenGroup)
	local bolt = u.loadImage("bolt2.png")
	bolt:translate(xLocation, -100)
	physics.addBody(bolt, "static", lightningMaterial) 
	screenGroup:insert(bolt)	
	bolt.name = "bolt"
	return bolt 
end

u.addBackground = function(screenGroup)
	local background = display.newImage( "images/backgroundIngame.png", true )

	--local background = u.loadImage("backgroundIngame.png")
	background:translate(display.screenOriginX, display.screenOriginY)
	u.centreObjectX(background)
	screenGroup:insert(background)
	return background
end

u.addStaticWink = function(screenGroup, isLeftHanded)
	local staticWink = u.loadImage("winky3.png")

	if isLeftHanded then
		staticWink:translate(display.screenOriginX + 20, display.screenOriginY + 20)
	else
		staticWink:translate(display.contentWidth - display.screenOriginX - 365, display.screenOriginY + 20)
	end

	screenGroup:insert(staticWink)
	return staticWink
end

u.addExitCover = function(screenGroup, colour, yLocation)
	local exitCover = u.loadImage("exitCover2.png")
	exitCover:translate(880, yLocation)
	u.addNewObject(exitCover, colour[1], colour[2], colour[3], screenGroup) 
	physics.addBody(exitCover, "static", exitCoverMaterial)  	
	return exitCover
end

u.addFloor = function(screenGroup, floorLength)
	local floor = u.loadImage("newGrass.png") 
	local offset = floorLength - 1020
	floor:translate(offset, 575)
	physics.addBody(floor, "static", grassMaterial)  	
	screenGroup:insert(floor)
	return floor
end

u.addCanTargetNoTopWood = function(screenGroup, xLocation, yLocation, sendBackgroundBack)
	local can = u.loadImage("tincan.png")
	u.addNewDynamicLightPicture(can, screenGroup)
	can:translate(xLocation, yLocation + 10)

	local wood1 = u.addWood(xLocation + 5, yLocation + 150, screenGroup)

	can:toBack()
	wood1:toBack()

	if sendBackgroundBack then
		background:toBack()
	end

	return can
end

u.addCanTarget = function(screenGroup, xLocation, yLocation)
	local can = u.addCanTargetNoTopWood(screenGroup, xLocation, yLocation, false)

	local wood2 = u.addWood(xLocation, yLocation - 795, screenGroup)

	wood2:toBack()

	background:toBack()

	return can
end

u.addWasp = function(screenGroup, xLocation, yLocation)
	local wasp = u.loadImage("wasp.png")
	
	physics.addBody(wasp, "kinematic", dynamicLightMaterial) 
	wasp:translate(xLocation, yLocation)
	screenGroup:insert(wasp)
	return wasp
end

u.getNumLives = function()
	local numLives = persistent.getValue("numLives")

	if numLives == nil then
		numLives = 0
	end

	print("Number of lives is " .. numLives)

	return numLives
end

u.getNumBoughtLives = function()
	local numLives = persistent.getValue("numBoughtLives")

	if numLives == nil then
		numLives = 0
	end

	print("Number of bought lives is " .. numLives)

	return numLives
end

u.hasUserLiked = function()
	local userLiked = persistent.getValue("userLiked")

	if userLiked == nil then
		userLiked = false
	end

	return userLiked
end

u.getPersonalBest = function()
	local personalBest = persistent.getValue("personalBest")

	if personalBest == nil then
		personalBest = 0
	end

	return personalBest
end

u.getLevelName = function(index)
	local levelName = "levels." .. levelMappings[index][1]

	return levelName
end

u.getLevelIndex = function(name)
	local index = 0
	print("asking for index for level " .. name)


	for i=1,#levelMappings do
		if levelMappings[i][1] == name then
			index = i
			break
		end
	end

	return index
end

u.getDefaultLives = function()
	return 50
end

u.persistMoreLives = function(numMoreLives)
	local numLives = u.getNumBoughtLives()
	local newBoughtLivesTotal = numLives + numMoreLives
	persistent.saveModule("numBoughtLives", numLives + numMoreLives)
	return newBoughtLivesTotal
end

u.getCountdownTimerEnd = function()
	local countdownEnd = persistent.getValue("countdownEnd")

	if countdownEnd == nil then
		countdownEnd = 0
	end

	return countdownEnd
end

u.persistCountdownTimerEnd = function(endTime)
	persistent.saveModule("countdownEnd", endTime)
end

u.getTimerTable = function(endTime)
	local diff = endTime - os.time()

	if diff < 1 then
		local r = {}
		r.secs = 0
		r.mins = 0
		return r
	else
		local mins = math.floor(diff / 60)
		local secs = diff - (mins * 60)
		local r = {}

		if secs < 10 then
			r.secs = "0" .. secs
		else
			r.secs = secs
		end

		r.mins = mins
		return r		
	end
end

u.addCentredText = function(text, yLocation, screenGroup, size)
	local textObject = display.newText(text, 0, yLocation, "GoodDog", size)
	u.centreObjectX(textObject)
	screenGroup:insert(textObject)
	return textObject
end

u.addBlackCentredText = function(text, yLocation, screenGroup, size)
	local textObject = u.addCentredText(text, yLocation, screenGroup, size)
	textObject:setTextColor(0,0,0)
	return textObject
end

u.addMenuButton = function(screenGroup, xLocation, yLocation)
	local menuButton = u.loadImage("menuButton.png")
	menuButton:translate(xLocation, yLocation)  
	screenGroup:insert(menuButton)
	return menuButton
end

u.decrementLife = function()
	print("decrementing lives")
	transitionData.numLives = transitionData.numLives - 1
	persistent.saveModule("numLives", transitionData.numLives)
end

u.addMenuBackground = function(screenGroup)
	local background = display.newImage( "images/menuBackground.png", true )
	--local background = u.loadImage("menuBackground.png")
	background:translate(display.screenOriginX, display.screenOriginY)
	u.centreObjectX(background)
	screenGroup:insert(background)
	return background
end

local function fblistener( event )
    if ( "session" == event.type ) then
	print("successfully connected to Facebook")
        -- upon successful login
        if ( "login" == event.phase ) then
        	facebookSession = true
        end

    elseif ( "request" == event.type ) then
        -- event.response is a JSON object from the FB server
        local response = event.response
        print( response )
    end
end

u.initialise = function()

	local foundZero = false

	for i = 1, 96 do 
		local currentStars = 0

		if foundZero == false then
			local levelName = u.getLevelName(i)
			currentStars = persistent.getValue(levelName)

			if currentStars == nil then
				currentStars = 0
				foundZero = true
			end
		end

		print(currentStars .. " stars for level index " .. i)

		starsStore[i] = currentStars
	end

	facebook.login( "151025625078894", fblistener, {"publish_stream"} )
end

u.getStarsForLevelIndex = function(index)
	print("asking for stars at index " .. index)
	return starsStore[index]
end

u.setStarsForLevelIndex = function(stars, index)
	starsStore[index] = stars
end

u.resetNumLives = function()
	local livesTotal = u.getDefaultLives() + u.getNumBoughtLives()
	transitionData.numLives = livesTotal
	persistent.saveModule("numLives", livesTotal)
end

u.persistLeftHanded = function(trueFalse)
	persistent.saveModule("leftHanded", trueFalse)
end

u.getLeftHanded = function()
	return persistent.getValue("leftHanded")
end

local function getBooleanValue(lookup)
	local isUnlocked = persistent.getValue(lookup)
	
	if isUnlocked then
		return true
	else
		return false
	end
end

u.hasUnlocked1 = function()
	return getBooleanValue("unlocked1")
end

u.hasUnlocked2 = function()
	return getBooleanValue("unlocked2")
end

u.unlock1 = function()
	persistent.saveModule("unlocked1", true)
end

u.unlock2 = function()
	persistent.saveModule("unlocked2", true)
end

u.postToFacebook = function(givenMessage, identifierForPersistence)
	if facebookSession then
		print("posting to Facebook")
		local attachment = {
        		name = "Come and play Tiddly Flicks too!",
        		link = "http://www.appappnaway.co.uk/tiddly-flicks",
	        	description = "What do you get if you cross a retro platform video game with a classic board game?  TIDDLY FLICKS! Play it now on Android, iPhone and iPad",
	        	picture = "http://www.appappnaway.co.uk/images/Icon290.png",
         		message = givenMessage
        	}
                
		facebook.request( "me/feed", "POST", attachment )
		persistent.saveModule("posted" .. identifierForPersistence, true)
	else
		print("no Facebook session")
	end
end

u.hasPosted = function(identifierForPersistence)
	return getBooleanValue("posted" .. identifierForPersistence)
end

u.hasEarnedBadgesWithHoleInOne = function()
	local numHIO = persistent.getValue("numHIO")

	if numHIO == nil then
		numHIO = 0
	end

	persistent.saveModule("numHIO", numHIO + 1)

	if (numHIO == 2) then
		persistent.saveModule("3HIO", true)
		return true
	end

	if (numHIO == 9) then
		persistent.saveModule("10HIO", true)
		return true
	end

	if (numHIO == 99) then
		persistent.saveModule("100HIO", true)
		return true
	end
end

u.hasAchieved3HIO = function()
	return getBooleanValue("3HIO")
end

u.hasAchieved10HIO = function()
	return getBooleanValue("10HIO")
end

u.hasAchieved100HIO = function()
	return getBooleanValue("100HIO")
end

u.hasAchieved3Consecutive = function()
	return getBooleanValue("3consecutive")
end

u.hasAchieved10Consecutive = function()
	return getBooleanValue("10consecutive")
end

local function split(pString, pPattern)
   local Table = {}
   local fpat = "(.-)" .. pPattern
   local last_end = 1
   local s, e, cap = pString:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
         table.insert(Table,cap)
      end
      last_end = e+1
      s, e, cap = pString:find(fpat, last_end)
   end
   if last_end <= #pString then
      cap = pString:sub(last_end)
      table.insert(Table, cap)
  end
 
   return Table
end

u.completedOrFailedToEarnBadge = function(completed, levelIndex)
	if completed then
		local previous = persistent.getValue("consecutive")

		if previous == nil then
			print("persisting single level")
			persistent.saveModule("consecutive", "1-levelIndex")
			return false
		else
			print("previous " .. previous)

			local tab = split(previous, "-") 

			print("previous num " .. tab[1])

			local alreadyDoneThisLevel = false
			local previousLevels = ""

			if tab[2] then
				previousLevels = tab[2] .. ":"
				print("previous levels " .. tab[2])

				local previousLevelsArr = split(tab[2], ":")


				for i = 1,  #previousLevelsArr do
					print(previousLevelsArr[i])

					if previousLevelsArr[i] == ("" .. levelIndex) then
						alreadyDoneThisLevel = true	
					end
				end
			end

			previousLevels = "-" .. previousLevels

			if alreadyDoneThisLevel == false then
				print("level not in sequence")
				local numConsec = tab[1]
				local newNumConsec = numConsec + 1
				local toPersist = newNumConsec .. previousLevels .. levelIndex 

				print("persisting " .. toPersist)

				persistent.saveModule("consecutive", toPersist)

				if newNumConsec == 3 then
					persistent.saveModule("3consecutive", true)
					return true
				elseif newNumConsec == 10 then
					persistent.saveModule("10consecutive", true)
					return true
				end
			end
		end
	else
		persistent.saveModule("consecutive", "0")
		return false
	end
end

u.hasCompleted32Levels = function()
	return starsStore[32] ~= 0
end

u.hasCompleted64Levels = function()
	return starsStore[64] ~= 0
end

local function countLevelsWith3Stars()
	local num3stars = 0

	for i = 1, 96 do 
		if starsStore[i] == 0 then
			break
		elseif starsStore[i] == 3 then
			num3stars = num3stars + 1
		end
	end

	return num3stars
end

u.hasCompleted20LevelsWith3Stars = function()
	if starsStore[20] == 0 then
		return false
	else
		return (countLevelsWith3Stars() > 19)
	end
end

u.hasCompleted32LevelsWith3Stars = function()
	if starsStore[32] == 0 then
		return false
	else
		return (countLevelsWith3Stars() > 31)

	end
end

u.hasCompleted64LevelsWith3Stars = function()
	if starsStore[64] == 0 then
		return false
	else
		return (countLevelsWith3Stars() > 63)

	end
end

function u.doSounds(yesNo)
	playSounds = yesNo
	persistent.saveModule("sound", yesNo)
end

function u.willPlaySounds()
	print("should I play sound?")
	playSounds = persistent.getValue("sound")

	if playSounds == nil then
		print("playSounds is nil")
		playSounds = true
	end

	return playSounds

end

return u

