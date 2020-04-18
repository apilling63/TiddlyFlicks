-----------------------------------------------------------------------------------------
--
-- training.lua
--
-----------------------------------------------------------------------------------------

-- allow this lua file to be used with storyboards
local transitionData = require "sceneTransitionData"
local utility = require "utility"
local t = {}
local store = require("store")
local initialised = 0
local result = 0
local testMode = 0
local storyboard = require "storyboard"
local callbackUponSuccessfulPurchase
local translations = require "translations"

local listOfProducts = 
{
    "extralevelscountry",
    "100lives",
    "250lives",
}

local function doPersistAfterPurchase(identifier)

	if identifier == listOfProducts[1] then
		utility.unlock1()
	elseif identifier == listOfProducts[2] then
		utility.unlock2()
	elseif identifier == listOfProducts[3] then
		utility.unlock3()
	else 
		--something horrible has gone wrong!!
		print("Cannot identify purchase product")
	end

end

local function uponClearingSuccessMessage(event)
	if "clicked" == event.action then
		timer.performWithDelay(10, callbackUponSuccessfulPurchase)
	end
end


local function transactionCallback( event )

	local transaction = {}

	if testMode == 0 then
		transaction = event.transaction
	end

    if testMode == 1 or transaction.state == "purchased" then
        print("Transaction successful!")

	if testMode == 0 then
        	print("productIdentifier", transaction.productIdentifier)
	        print("receipt", transaction.receipt)
	        print("transactionIdentifier", transaction.identifier)
        	print("date", transaction.date)
	end

	local alertText = translations.getPhrase("IAP SUCCESS")
	local alertTitle = translations.getPhrase("PURCHASE")

	native.showAlert( alertTitle, alertText, { "OK" }, uponClearingSuccessMessage)

	if testMode == 0 then
		doPersistAfterPurchase(transaction.productIdentifier)
	end

	result = 1
    elseif testMode == 2 or transaction.state == "restored" then
        print("Transaction restored (from previous session)")
	if testMode == 0 then
	        print("productIdentifier", transaction.productIdentifier)
        	print("receipt", transaction.receipt)
	        print("transactionIdentifier", transaction.identifier)
        	print("date", transaction.date)
	        print("originalReceipt", transaction.originalReceipt)
        	print("originalTransactionIdentifier", transaction.originalIdentifier)
	        print("originalDate", transaction.originalDate)
	end
	result = 1
	--native.showAlert( "Purchase", "Purchases have been restored", { "OK" })

    elseif testMode == 3 or transaction.state == "cancelled" then
        print("User cancelled transaction")
	local alertText = translations.getPhrase("IAP CANCELLED")
	local alertTitle = translations.getPhrase("PURCHASE")

	native.showAlert( alertTitle, alertText, { "OK" })
	result = 4
    elseif testMode == 4 or transaction.state == "failed" then
	local alertText = translations.getPhrase("IAP FAILED")
	local alertTitle = translations.getPhrase("PURCHASE")

	native.showAlert( alertTitle, alertText, { "OK" })
        print("Transaction failed, type:", transaction.errorType, transaction.errorString)
	result = 4
    elseif testMode == 5 or transaction.state == "refunded" then
	--native.showAlert( "Purchase", "A previous purchase was refunded", { "OK" })
	result = 4
        print("unknown event")
    else
	local alertText = translations.getPhrase("IAP DID NOT SUCCEED")
	local alertTitle = translations.getPhrase("PURCHASE")

	native.showAlert( alertTitle, alertText, { "OK" })
	result = 4
        print("unknown event")
    end

    -- Once we are done with a transaction, call this to tell the store
    -- we are done with the transaction.
    -- If you are providing downloadable content, wait to call this until
    -- after the download completes.

	if testMode == 0 then
	    store.finishTransaction( transaction )
	end
end

t.purchase = function(itemToBuyIndex, callbackUponSuccess)
	result = 0
	print(initialised)

	if initialised == 1 then
		print("doing purchase")
		callbackUponSuccessfulPurchase = callbackUponSuccess

		if testMode > 0 then
			transactionCallback()
		else 
			store.purchase({listOfProducts[itemToBuyIndex]})
		end
	elseif initialised == 3 then
		print("cannot purchase")
		local alertText = translations.getPhrase("SYSTEM IAP")
		local alertTitle = translations.getPhrase("SORRY")

		native.showAlert( alertTitle, alertText, { "OK" })
		result = 3

	elseif initialised == 2 then
		local alertText = translations.getPhrase("DEVICE NO IAP")
		local alertTitle = translations.getPhrase("SORRY")

		native.showAlert( alertTitle, alertText, { "OK" })
	end
	
	return result
end



t.initialise = function(test)
	if test > 0 then
		native.showAlert( "TEST", "In store test mode", { "OK" })
		print("IN TEST MODE")
		initialised = 1
		testMode = test
	elseif initialised == 0 then

		-- Connect to store at startup, if available.
		if store.availableStores.apple then
		    	print("Using Apple's in-app purchase system.")
			store.init( "apple", transactionCallback )
			initialised = 1
		elseif store.availableStores.google then
		    	print("Using Google's Android In-App Billing system.")
			store.init( "google", transactionCallback )
			initialised = 1
		else
			print("In-app purchases is not supported on this system/device.")
			initialised = 2
		end

		if initialised == 1 and store.canMakePurchases == false then
			initialised = 3
		end
	end
end

return t