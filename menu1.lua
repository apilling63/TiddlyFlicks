-----------------------------------------------------------------------------------------
--
-- menu.lua
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
local math = require "math"
local translations = require "translations"
local gameNoise = audio.loadSound("sounds/country_sounds.mp3")

local playButton
local howToPlayButton
local credits
local soundOnIcon
local soundOffIcon
local ad
local leftHanded
local rightHanded
local merchandise
local achievements

local backgroundNoise = audio.loadSound("sounds/menu_music.mp3")

local function doPlay(event)
	if "began" == event.phase then
		transitionData.nextScene = "levelsScene"
		transitionData.numLives = numLives
		playButton:setFillColor(255, 255, 0)

		local closure = function()
			storyboard.gotoScene( "levelsScene") 
		end

		timer.performWithDelay(50, closure)
	end
end

local function showCredits(event)
	if "began" == event.phase then
		credits:setFillColor(255, 255, 0)
		transitionData.nextScene = "credits2"
		local closure = function()
			storyboard.gotoScene( "credits2") 
		end

		timer.performWithDelay(50, closure)
	end
end

local function showHowToPlay(event)
	if "began" == event.phase then
		howToPlayButton:setFillColor(255, 255, 0)
		transitionData.nextScene = "howToPlay1"

		local closure = function()
			storyboard.gotoScene( "howToPlay1") 
		end

		timer.performWithDelay(50, closure)
	end
end

local function doRateApp(event)
    if "clicked" == event.action then

        local i = event.index

        if 1 == i then
		-- rate the app!!!
		print("user has chosen to rate the app") 
		local options =
		{
		   iOSAppId = "646894783",
		   supportedAndroidStores = { "google" },
		}

		local closure = function()
			print("rating the app")
			native.showPopup("rateApp", options) 
		end

		timer.performWithDelay(1, closure)
        end
    end
end

local function goToGameLink(event)
    if "clicked" == event.action then

        local i = event.index

        if 1 == i then
		local ad = myRevMob.getAd()
		ad:open()
	end
    end
end

-- what to do when the screen loads
function scene:createScene(event)

	local screenGroup = self.view
	utility.addMenuBackground(screenGroup)

	local title = utility.loadImage("titleImage.png") 
	utility.centreObjectX(title)
	title.y = 5
	screenGroup:insert(title)

	playButton = utility.loadImage("playButton.png") 
	utility.centreObjectX(playButton)
	playButton:translate(-250, 400)
	screenGroup:insert(playButton)

	howToPlayButton = utility.loadImage("howToPlay.png") 
	utility.centreObjectX(howToPlayButton)
	howToPlayButton.y = 400
	screenGroup:insert(howToPlayButton)

	credits = utility.loadImage("credits.png") 
	utility.centreObjectX(credits)
	credits:translate(250, 400)
	screenGroup:insert(credits)

	soundOnIcon = utility.loadImage("soundOn.png") 
	utility.centreObjectX(soundOnIcon)
	soundOnIcon:translate(100, 501)
	screenGroup:insert(soundOnIcon)

	soundOffIcon = utility.loadImage("soundOff.png") 
	utility.centreObjectX(soundOffIcon)
	soundOffIcon:translate(100, 500)
	screenGroup:insert(soundOffIcon)
	soundOffIcon:toBack()

	leftHanded = utility.loadImage("leftHanded.png") 
	utility.centreObjectX(leftHanded)
	leftHanded:translate(-100, 500)
	screenGroup:insert(leftHanded)
	leftHanded:toBack()

	rightHanded = utility.loadImage("rightHanded.png") 
	utility.centreObjectX(rightHanded)
	rightHanded:translate(-100, 500)
	screenGroup:insert(rightHanded)

	merchandise = utility.loadImage("merchandise.png") 
	utility.centreObjectX(merchandise)
	merchandise:translate(300, 500)
	screenGroup:insert(merchandise)

	achievements = utility.loadImage("achievements.png") 
	utility.centreObjectX(achievements)
	achievements:translate(-300, 500)
	screenGroup:insert(achievements)

	if utility.willPlaySounds() == false then
		soundOnIcon:toBack()
		soundOffIcon:toFront()
	end 

	if utility.getLeftHanded() then
		transitionData.isLeftHanded = true
		leftHanded:toFront()
		leftHanded.current = true
	end
end

local function toggleHand(event)
	if event.phase == "began" then
		if transitionData.isLeftHanded then
			leftHanded:toBack()
			transitionData.isLeftHanded = false
			utility.persistLeftHanded(false)
		else
			transitionData.isLeftHanded = true
			leftHanded:toFront()
			utility.persistLeftHanded(true)
		end	
	end
end

local function toggleSound(event)
	if event.phase == "began" then
		if utility.willPlaySounds() == true then
			print("turn off sound")
			utility.stopSound()
			utility.doSounds(false)
			soundOnIcon:toBack()
			soundOffIcon:toFront()
		else
			print("turn on sound")
			soundOffIcon:toBack()
			soundOnIcon:toFront()
			utility.doSounds(true)
			utility.playSoundWithOptions(backgroundNoise, {loops = -1})
		end
	end
end

local function goToMerchandise(event)
	if event.phase == "began" then
		system.openURL( "http://www.appappnaway.spreadshirt.co.uk" ) 
	end
end

local function goToAchievements(event)
	if event.phase == "began" then
		storyboard.gotoScene( "achievements") 
	end
end

function scene:enterScene(event)
	storyboard.purgeScene(transitionData.currentScene)
	playButton:addEventListener("touch", doPlay)
	transitionData.currentScene = "menu1"
	howToPlayButton:addEventListener("touch", showHowToPlay) 
	credits:addEventListener("touch", showCredits) 
	soundOnIcon:addEventListener("touch", toggleSound) 
	merchandise:addEventListener("touch", goToMerchandise)  
 	achievements:addEventListener("touch", goToAchievements)  

	rightHanded:addEventListener("touch", toggleHand)
	print("entering Menu")
	utility.stopSound()
	utility.playSoundWithOptions(backgroundNoise, {loops = -1})

	numLives = utility.getNumLives()

	if numLives == nil or numLives < 1 then
		local numDefaultLives = utility.getDefaultLives()
		local boughtLives = utility.getNumBoughtLives()
		numLives = numDefaultLives + boughtLives
	end

	if transitionData.firstScene then
		transitionData.firstScene = false
		native.showAlert( "Tiddly values your opinion", "Would you like to rate him?", { "Sure!", "Maybe later" }, doRateApp )
	elseif myRevMob.isAdAvailable() then
		print("not first scene")
		--native.showAlert( "FREE GAME FROM OUR PARTNER", "Would you like to try another cool free game?  This may take a few moments to connect", { "Sure!", "No thanks" }, goToGameLink )
	end

	translations.setLanguage("en")
end

function scene:exitScene(event)
	playButton:removeEventListener("touch", doPlay)
	howToPlayButton:removeEventListener("touch", showHowToPlay) 
	credits:removeEventListener("touch", showCredits) 
	soundOnIcon:removeEventListener("touch", toggleSound) 
	rightHanded:removeEventListener("touch", toggleHand)
	merchandise:removeEventListener("touch", goToMerchandise)  
	achievements:removeEventListener("touch", goToAchievements)  

end

function scene:destroyScene(event)
end

scene:addEventListener("createScene", scene)
scene:addEventListener("enterScene", scene)
scene:addEventListener("exitScene", scene)
scene:addEventListener("destroyScene", scene)

return scene