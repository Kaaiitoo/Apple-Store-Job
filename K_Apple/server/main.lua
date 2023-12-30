ESX = nil
local PlayersTransforming  = {}
local PlayersSelling       = {}
local PlayersHarvesting = {}
local phone = 1
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

if Config.MaxInService ~= -1 then
	TriggerEvent('esx_service:activateService', 'apple', Config.MaxInService)
end

TriggerEvent('esx_phone:registerNumber', 'apple', _U('apple_client'), true, true)
TriggerEvent('esx_society:registerSociety', 'apple', 'Raffineur', 'society_apple', 'society_apple', 'society_apple', {type = 'private'})
local function Harvest(source, zone)
	if PlayersHarvesting[source] == true then

		local xPlayer  = ESX.GetPlayerFromId(source)
		if zone == "RecupPiece" then
			local itemQuantity = xPlayer.getInventoryItem('matos').count
			if itemQuantity >= 50 then
				TriggerClientEvent('esx:showNotification', source, _U('not_enough_place'))
				return
			else
				SetTimeout(1800, function()
					xPlayer.addInventoryItem('matos', 1)
					Harvest(source, zone)
				end)
			end
		end
	end
end

RegisterServerEvent('K_Apple:startHarvest')
AddEventHandler('K_Apple:startHarvest', function(zone)
	local _source = source
  	
	if PlayersHarvesting[_source] == false then
		TriggerClientEvent('esx:showNotification', _source, '~r~C\'est pas bien de glitch ~w~')
		PlayersHarvesting[_source]=false
	else
		PlayersHarvesting[_source]=true
		TriggerClientEvent('esx:showNotification', _source, _U('matos_taken'))  
		Harvest(_source,zone)
	end
end)


RegisterServerEvent('K_Apple:stopHarvest')
AddEventHandler('K_Apple:stopHarvest', function()
	local _source = source
	
	if PlayersHarvesting[_source] == true then
		PlayersHarvesting[_source]=false
		TriggerClientEvent('esx:showNotification', _source, 'Vous sortez de la ~r~zone')
	else
		TriggerClientEvent('esx:showNotification', _source, 'Vous pouvez ~g~récolter')
		PlayersHarvesting[_source]=true
	end
end)


local function Transform(source, zone)

	if PlayersTransforming[source] == true then

		local xPlayer  = ESX.GetPlayerFromId(source)
		if zone == "TraitementPiece" then
			local itemQuantity = xPlayer.getInventoryItem('matos').count
			
			if itemQuantity <= 0 then
				TriggerClientEvent('esx:showNotification', source, _U('not_enough_raffine'))
				return
			else
				local rand = math.random(0,100)
				if (rand >= 98) then
					SetTimeout(1800, function()
						xPlayer.removeInventoryItem('matos', 1)
						xPlayer.addInventoryItem('coque', 1)
						TriggerClientEvent('esx:showNotification', source, _U('not_enough_raffine'))
						Transform(source, zone)
					end)
				else
					SetTimeout(1800, function()
						xPlayer.removeInventoryItem('matos', 1)
						xPlayer.addInventoryItem('coque', 1)
				
						Transform(source, zone)
					end)
				end
			end
		elseif zone == "TraitementFinal" then
			local itemQuantity = xPlayer.getInventoryItem('coque').count
			if itemQuantity <= 0 then
				TriggerClientEvent('esx:showNotification', source, _U('not_enough_matos'))
				return
			else
				SetTimeout(1800, function()
					xPlayer.removeInventoryItem('coque', 1)
					xPlayer.addInventoryItem('phone', 1)
		  
					Transform(source, zone)	  
				end)
			end
		end
	end	
end	

RegisterServerEvent('K_Apple:startTransform')
AddEventHandler('K_Apple:startTransform', function(zone)
	local _source = source
  	
	if PlayersTransforming[_source] == false then
		TriggerClientEvent('esx:showNotification', _source, '~r~C\'est pas bien de glitch ~w~')
		PlayersTransforming[_source]=false
	else
		PlayersTransforming[_source]=true
		TriggerClientEvent('esx:showNotification', _source, _U('transforming_in_progress')) 
		Transform(_source,zone)
	end
end)

RegisterServerEvent('K_Apple:stopTransform')
AddEventHandler('K_Apple:stopTransform', function()

	local _source = source
	
	if PlayersTransforming[_source] == true then
		PlayersTransforming[_source]=false
		TriggerClientEvent('esx:showNotification', _source, 'Vous sortez de la ~r~zone')
		
	else
		TriggerClientEvent('esx:showNotification', _source, 'Vous pouvez ~g~transformer vos matériaux')
		PlayersTransforming[_source]=true
		
	end
end)

local function Sell(source, zone)

	if PlayersSelling[source] == true then
		local xPlayer  = ESX.GetPlayerFromId(source)
		local NombreFuel = xPlayer.getInventoryItem('phone').count
		
		if zone == 'Vente' then
			if xPlayer.getInventoryItem('phone').count <= 0 then
				phone = 0
			else
				phone = 1
			end
			
		
			if phone == 0 then
				TriggerClientEvent('esx:showNotification', source, _U('no_product_sale'))
				return
			elseif xPlayer.getInventoryItem('phone').count <= 0 then
				TriggerClientEvent('esx:showNotification', source, _U('no_fuel_sale'))
				phone = 0
				return
			else
				if (phone == 1) then
					SetTimeout(1100, function()
						local argent = math.random(2,4)
						local argentTotal = argent * NombreFuel
						local money = math.random(2,4)
						local moneyTotal = money * NombreFuel
						xPlayer.removeInventoryItem('phone', NombreFuel)
						local societyAccount = nil

						TriggerEvent('esx_addonaccount:getSharedAccount', 'society_apple', function(account)
							societyAccount = account
						end)
						if societyAccount ~= nil then
						
							xPlayer.addMoney(argentTotal)
							societyAccount.addMoney(moneyTotal)
		    				TriggerEvent('log:runSociete', society, moneyTotal, argentTotal)
							TriggerClientEvent('esx:showNotification', xPlayer.source, _U('have_earned') .. argentTotal)
							TriggerClientEvent('esx:showNotification', xPlayer.source, _U('comp_earned') .. moneyTotal)
						end
						Sell(source,zone)
					end)
				end
				
			end
		end
	end
end

RegisterServerEvent('K_Apple:startSell')
AddEventHandler('K_Apple:startSell', function(zone)

	local _source = source
	
	if PlayersSelling[_source] == false then
		TriggerClientEvent('esx:showNotification', _source, '~r~C\'est pas bien de glitch ~w~')
		PlayersSelling[_source]=false
	else
		PlayersSelling[_source]=true
		TriggerClientEvent('esx:showNotification', _source, _U('sale_in_prog'))
		Sell(_source, zone)
	end

end)

RegisterServerEvent('K_Apple:stopSell')
AddEventHandler('K_Apple:stopSell', function()

	local _source = source
	
	if PlayersSelling[_source] == true then
		PlayersSelling[_source]=false
		TriggerClientEvent('esx:showNotification', _source, 'Vous sortez de la ~r~zone')
		
	else
		TriggerClientEvent('esx:showNotification', _source, 'Vous pouvez ~g~vendre')
		PlayersSelling[_source]=true
	end

end)

RegisterServerEvent('K_Apple:getStockItem')
AddEventHandler('K_Apple:getStockItem', function(itemName, count)

	local xPlayer = ESX.GetPlayerFromId(source)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_apple', function(inventory)

		local item = inventory.getItem(itemName)

		if item.count >= count then
			inventory.removeItem(itemName, count)
			xPlayer.addInventoryItem(itemName, count)
		else
			TriggerClientEvent('esx:showNotification', xPlayer.source, _U('quantity_invalid'))
		end

		TriggerClientEvent('esx:showNotification', xPlayer.source, _U('have_withdrawn') .. count .. ' ' .. item.label)

	end)

end)

ESX.RegisterServerCallback('K_Apple:getStockItems', function(source, cb)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_apple', function(inventory)
		cb(inventory.items)
	end)

end)

RegisterServerEvent('K_Apple:putStockItems')
AddEventHandler('K_Apple:putStockItems', function(itemName, count)

	local xPlayer = ESX.GetPlayerFromId(source)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_apple', function(inventory)

		local item = inventory.getItem(itemName)

		if item.count >= 0 then
			xPlayer.removeInventoryItem(itemName, count)
			inventory.addItem(itemName, count)
		else
			TriggerClientEvent('esx:showNotification', xPlayer.source, _U('quantity_invalid'))
		end

		TriggerClientEvent('esx:showNotification', xPlayer.source, _U('added') .. count .. ' ' .. item.label)

	end)
end)

ESX.RegisterServerCallback('K_Apple:getPlayerInventory', function(source, cb)

	local xPlayer    = ESX.GetPlayerFromId(source)
	local items      = xPlayer.inventory

	cb({
		items      = items
	})

end)


