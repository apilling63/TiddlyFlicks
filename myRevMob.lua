-----------------------------------------------------------------------------------------
--
-- myRevMob.lua
--
-----------------------------------------------------------------------------------------

local t = {}

local initialised = false
local RevMob = require("revmob")
local ad
local isAdAvailable = false

local function revmobListener(event)
	if event.type == "adReceived" then
		print("ad available")
		isAdAvailable = true
	end
end

local function loadAd()
	ad = RevMob.createAdLink(revmobListener)
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
	end
end

t.getAd = function()
	print("promoting ad")
	isAdAvailable = false
	timer.performWithDelay(5000, loadAd)
	return ad
end

t.isAdAvailable = function()
	return isAdAvailable
end

return t