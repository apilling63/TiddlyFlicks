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

	if testMode > 0 then
		result = testMode
		native.showAlert( "Purchase", "The purchase was successful", { "OK" }, uponClearingSuccessMessage)
		return
	end

    local transaction = event.transaction

    if transaction.state == "purchased" then
        print("Transaction successful!")
        print("productIdentifier", transaction.productIdentifier)
        print("receipt", transaction.receipt)
        print("transactionIdentifier", transaction.identifier)
        print("date", transaction.date)
	native.showAlert( "Purchase", "The purchase was successful", { "OK" }, uponClearingSuccessMessage)

	doPersistAfterPurchase(transaction.productIdentifier)
	result = 1
    elseif  transaction.state == "restored" then
        print("Transaction restored (from previous session)")
        print("productIdentifier", transaction.productIdentifier)
        print("receipt", transaction.receipt)
        print("transactionIdentifier", transaction.identifier)
        print("date", transaction.date)
        print("originalReceipt", transaction.originalReceipt)
        print("originalTransactionIdentifier", transaction.originalIdentifier)
        print("originalDate", transaction.originalDate)
	result = 1
	native.showAlert( "Purchase", "Purchases have been restored", { "OK" })

    elseif transaction.state == "cancelled" then
        print("User cancelled transaction")
	native.showAlert( "Purchase", "The purchase was cancelled, you will not be charged", { "OK" })
	result = 4
    elseif transaction.state == "failed" then
	native.showAlert( "Purchase", "The purchase failed, you will not be charged", { "OK" })
        print("Transaction failed, type:", transaction.errorType, transaction.errorString)
	result = 4
    elseif transaction.state == "refunded" then
	native.showAlert( "Purchase", "A previous purchase was refunded", { "OK" })
	result = 4
        print("unknown event")
    else
	native.showAlert( "Purchase", "The purchase did not succeed, you will not be charged", { "OK" })
	result = 4
        print("unknown event")
    end

    -- Once we are done with a transaction, call this to tell the store
    -- we are done with the transaction.
    -- If you are providing downloadable content, wait to call this until
    -- after the download completes.
    store.finishTransaction( transaction )

end

t.purchase = function(itemToBuyIndex, callbackUponSuccess)
	result = 0
	print(initialised)

	if initialised == 1 then
		print("doing purchase")
		callbackUponSuccessfulPurchase = callbackUponSuccess

		if testMode > 0 then
			transactionCallback()
			doPersistAfterPurchase(listOfProducts[itemToBuyIndex])
		else 
			store.purchase({listOfProducts[itemToBuyIndex]})
		end
	elseif initialised == 3 then
		print("cannot purchase")
		native.showAlert( "Sorry", "You can't make purchases on this system", { "OK" })
		result = 3

	elseif initialised == 2 then
		native.showAlert( "Sorry", "In app purchases not supported on this system or device. Please activate purchases and try again via the levels page", { "OK" })
	end
	
	return result
end



t.initialise = function(test)
	if test > 0 then
		native.showAlert( "In store test mode", { "OK" })
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