-----------------------------------------------------------------------------------------
--
-- myRevMob.lua
--
-----------------------------------------------------------------------------------------

local t = {}

local initialised = false
local RevMob = require("revmob")
local ad
local fullscreen
local isAdAvailable = false
local isFSAvailable = false

local function revmobFSListener(event)
	if event.type == "adReceived" then
		print("fullscreen ad available")
		isFSAvailable = true
	end
end

local function revmobListener(event)
	if event.type == "adReceived" then
		print("ad available")
		isAdAvailable = true
	end
end

local function loadAd()
	ad = RevMob.createAdLink(revmobListener)
end

local function loadFullAd()
	fullscreen = RevMob.createFullscreen(revmobFSListener)
end

t.initialise = function()
	if initialised == false then
		local REVMOB_IDS = { ["Android"] = "51879287b0cd14e1cc000098", ["iPhone OS"] = "518792633ee972d39c0000cf" }
		RevMob.startSession(REVMOB_IDS)
		RevMob.setTimeoutInSeconds(5)
		initialised = true

		--RevMob.setTestingMode(RevMob.TEST_WITH_ADS)
		--RevMob.setTestingMode(RevMob.TEST_WITHOUT_ADS)
		--RevMob.setTestingMode(RevMob.TEST_DISABLED)
		loadAd()
		loadFullAd()
	end
end

t.getAd = function()
	print("promoting ad")
	isAdAvailable = false
	timer.performWithDelay(5000, loadAd)
	return ad
end

t.getFS = function()
	print("promoting FS")
	isFSAvailable = false
	timer.performWithDelay(5000, loadFullAd)
	return fullscreen
end

t.isAdAvailable = function()
	return isAdAvailable
end

t.isFSAvailable = function()
	return isFSAvailable
end

return t