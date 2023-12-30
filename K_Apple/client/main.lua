--################################## KAITO POUR FIVE DEV #####################################

local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

local PlayerData                = {}
local GUI                       = {}
local HasAlreadyEnteredMarker   = false
local LastZone                  = nil
local CurrentAction             = nil
local CurrentActionMsg          = ''
local CurrentActionData         = {}
local JobBlips                = {}
local publicBlip = false
ESX                             = nil
GUI.Time                        = 0

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

function TeleportFadeEffect(entity, coords)

	Citizen.CreateThread(function()

		DoScreenFadeOut(800)

		while not IsScreenFadedOut() do
			Citizen.Wait(0)
		end

		ESX.Game.Teleport(entity, coords, function()
			DoScreenFadeIn(800)
		end)

	end)
end

function OpenCloakroomMenu()

	ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'cloakroom',
		{
			title    = _U('cloakroom'),
			align    = 'top-left',
			elements = {
				{label = _U('civil_clothes'), value = 'citizen_wear'},
				{label = _U('apple_clothes'), value = 'apple_wear'},
			},
		},
		function(data, menu)

			menu.close()

			if data.current.value == 'citizen_wear' then
				ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
					TriggerEvent('skinchanger:loadSkin', skin)
				end)
			end

			if data.current.value == 'apple_wear' then
				ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
					if skin.sex == 0 then
						TriggerEvent('skinchanger:loadClothes', skin, jobSkin.skin_male)
					else
						TriggerEvent('skinchanger:loadClothes', skin, jobSkin.skin_female)
					end
				end)
			end

			CurrentAction     = 'apple_actions_menu'
			CurrentActionMsg  = _U('open_menu')
			CurrentActionData = {}
		end,
		function(data, menu)
			menu.close()
		end
	)

end
--################################## KAITO POUR FIVE DEV #####################################

function OpenAppleActionsMenu()

	local elements = {
        {label = _U('cloakroom'), value = 'cloakroom'}
	}
	if Config.EnablePlayerManagement and PlayerData.job ~= nil and (PlayerData.job.grade_name ~= 'recrue' and PlayerData.job.grade_name ~= 'novice')then -- Config.EnablePlayerManagement and PlayerData.job ~= nil and PlayerData.job.grade_name == 'boss'
		table.insert(elements, {label = _U('deposit_stock'), value = 'put_stock'})
	end 
	
	if Config.EnablePlayerManagement and PlayerData.job ~= nil and (PlayerData.job.grade_name ~= 'recrue' and PlayerData.job.grade_name ~= 'novice')then -- Config.EnablePlayerManagement and PlayerData.job ~= nil and PlayerData.job.grade_name == 'boss'
		table.insert(elements, {label = _U('take_stock'), value = 'get_stock'})
	end
  
	if Config.EnablePlayerManagement and PlayerData.job ~= nil and PlayerData.job.grade_name == 'boss' then -- Config.EnablePlayerManagement and PlayerData.job ~= nil and PlayerData.job.grade_name == 'boss'
		table.insert(elements, {label = _U('boss_actions'), value = 'boss_actions'})
	end

	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'apple_actions',
		{
			title    = 'Apple',
			align    = 'top-left',
			elements = elements
		},
		
		function(data, menu)
			if data.current.value == 'cloakroom' then
				OpenCloakroomMenu()
			end

			if data.current.value == 'put_stock' then
				OpenPutStocksMenu()
			end

			if data.current.value == 'get_stock' then
				OpenGetStocksMenu()
			end

			if data.current.value == 'boss_actions' then
				TriggerEvent('esx_society:openBossMenu', 'apple', function(data, menu)
					menu.close()
				end)
			end

		end,
		function(data, menu)

			menu.close()

			CurrentAction     = 'apple_actions_menu'
			CurrentActionMsg  = _U('press_to_open')
			CurrentActionData = {}

		end
	)
end

function OpenVehicleSpawnerMenu()

	ESX.UI.Menu.CloseAll()

	if Config.EnableSocietyOwnedVehicles then

		local elements = {}

		ESX.TriggerServerCallback('esx_society:getVehiclesInGarage', function(vehicles)

			for i=1, #vehicles, 1 do
				table.insert(elements, {label = GetDisplayNameFromVehicleModel(vehicles[i].model) .. ' [' .. vehicles[i].plate .. ']', value = vehicles[i]})
			end

			ESX.UI.Menu.Open(
				'default', GetCurrentResourceName(), 'vehicle_spawner',
				{
					title    = _U('veh_menu'),
					align    = 'top-left',
					elements = elements,
				},
				function(data, menu)

					menu.close()

					local vehicleProps = data.current.value

					ESX.Game.SpawnVehicle(vehicleProps.model, Config.Zones.VehicleSpawnPoint.Pos, 90.0, function(vehicle)
						ESX.Game.SetVehicleProperties(vehicle, vehicleProps)
						local playerPed = GetPlayerPed(-1)
						TaskWarpPedIntoVehicle(playerPed,  vehicle,  -1)
						local playerPed = GetPlayerPed(-1)
						local playerVeh = GetVehiclePedIsIn(playerPed, true)
						SetVehicleNumberPlateText(playerVeh, 'FUEL WORK')
					end)

					TriggerServerEvent('esx_society:removeVehicleFromGarage', 'apple', vehicleProps)

				end,
				function(data, menu)

					menu.close()

					CurrentAction     = 'vehicle_spawner_menu'
					CurrentActionMsg  = _U('spawn_veh')
					CurrentActionData = {}

				end
			)

		end, 'apple')

	else
	
		local elements = {
			{label = 'Camion de Travail',  value = 'burrito'},
		}
		
		ESX.UI.Menu.Open(
			'default', GetCurrentResourceName(), 'vehicle_spawner',
			{
				title    = _U('veh_menu'),
				align    = 'top-left',
				elements = elements,
			},
			function(data, menu)

				menu.close()

				local model = data.current.value
		
				ESX.Game.SpawnVehicle(model, Config.Zones.VehicleSpawnPoint.Pos, 56.326, function(vehicle)
					local playerPed = GetPlayerPed(-1)
					TaskWarpPedIntoVehicle(playerPed,  vehicle,  -1)
				end)
			end,
			function(data, menu)

				menu.close()

				CurrentAction     = 'vehicle_spawner_menu'
				CurrentActionMsg  = _U('spawn_veh')
				CurrentActionData = {}

			end
		)
	end
end

function OpenMobileAppleActionsMenu()

	ESX.UI.Menu.CloseAll()
	if PlayerData.job ~= nil and PlayerData.job.grade_name == 'boss' then
		ESX.UI.Menu.Open(
			'default', GetCurrentResourceName(), 'mobile_apple_actions',
			{
				title    = 'Apple',
				align    = 'top-left',
				elements = {
					{label = _U('billing'), value = 'billing'}
				}
			},
			function(data, menu)

				if data.current.value == 'billing' then

					ESX.UI.Menu.Open(
						'dialog', GetCurrentResourceName(), 'billing',
						{
							title = _U('invoice_amount')
						},
						function(data, menu)

							local amount = tonumber(data.value)

							if amount == nil or amount <= 0 then
								ESX.ShowNotification(_U('amount_invalid'))
							else
								menu.close()

								local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

								if closestPlayer == -1 or closestDistance > 3.0 then
									ESX.ShowNotification(_U('no_players_near'))
								else
									local playerPed        = GetPlayerPed(-1)

									Citizen.CreateThread(function()
										TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TIME_OF_DEATH', 0, true)
										Citizen.Wait(5000)
										ClearPedTasks(playerPed)
										TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(closestPlayer), 'society_apple', 'Apple', amount)
									end)
								end
							end
						end,
						function(data, menu)
							menu.close()
						end
					)
				end
			end,
			function(data, menu)
				menu.close()
			end
		)
	end
end

function OpenGetStocksMenu()

	ESX.TriggerServerCallback('K_Apple:getStockItems', function(items)

		print(json.encode(items))

		local elements = {}

		for i=1, #items, 1 do
			if (items[i].count ~= 0) then
				table.insert(elements, {label = 'x' .. items[i].count .. ' ' .. items[i].label, value = items[i].name})
			end
		end

		ESX.UI.Menu.Open(
			'default', GetCurrentResourceName(), 'stocks_menu',
			{
				title    = 'Apple Stock',
				align    = 'top-left',
				elements = elements
			},
			function(data, menu)

				local itemName = data.current.value

				ESX.UI.Menu.Open(
					'dialog', GetCurrentResourceName(), 'stocks_menu_get_item_count',
					{
						title = _U('quantity')
					},
					function(data2, menu2)
		
						local count = tonumber(data2.value)

						if count == nil or count <= 0 then
							ESX.ShowNotification(_U('quantity_invalid'))
						else
							menu2.close()
							menu.close()
							OpenGetStocksMenu()

							TriggerServerEvent('K_Apple:getStockItem', itemName, count)
						end

					end,
					function(data2, menu2)
						menu2.close()
					end
				)

			end,
			function(data, menu)
				menu.close()
			end
		)
	end)
end

function OpenPutStocksMenu()

	ESX.TriggerServerCallback('K_Apple:getPlayerInventory', function(inventory)

		local elements = {}

		for i=1, #inventory.items, 1 do

			local item = inventory.items[i]

			if item.count > 0 then
				table.insert(elements, {label = item.label .. ' x' .. item.count, type = 'item_standard', value = item.name})
			end

		end

		ESX.UI.Menu.Open(
			'default', GetCurrentResourceName(), 'stocks_menu',
			{
				title    = _U('inventory'),
				elements = elements
			},
			function(data, menu)

				local itemName = data.current.value

				ESX.UI.Menu.Open(
					'dialog', GetCurrentResourceName(), 'stocks_menu_put_item_count',
					{
						title = _U('quantity')
					},
					function(data2, menu2)

						local count = tonumber(data2.value)

						if count == nil or count <= 0 then
							ESX.ShowNotification(_U('quantity_invalid'))
						else
							menu2.close()
							menu.close()
							OpenPutStocksMenu()

							TriggerServerEvent('K_Apple:putStockItems', itemName, count)
						end

					end,
					function(data2, menu2)
						menu2.close()
					end
				)

			end,
			function(data, menu)
				menu.close()
			end
		)

	end)

end


RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	PlayerData = xPlayer
	blips()
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job
	deleteBlips()
	blips()
end)

AddEventHandler('K_Apple:hasEnteredMarker', function(zone)
	if zone == 'RecupPiece' and PlayerData.job ~= nil and PlayerData.job.name == 'apple'  then
		CurrentAction     = 'raisin_harvest'
		CurrentActionMsg  = _U('press_collect')
		CurrentActionData = {zone= zone}
	end
		
	if zone == 'TraitementPiece' and PlayerData.job ~= nil and PlayerData.job.name == 'apple'  then
		CurrentAction     = 'vine_traitement'
		CurrentActionMsg  = _U('press_traitement_raffine')
		CurrentActionData = {zone= zone}
	end		
		
	if zone == 'TraitementFinal' and PlayerData.job ~= nil and PlayerData.job.name == 'apple'  then
		CurrentAction     = 'jus_traitement'
		CurrentActionMsg  = _U('press_traitement')
		CurrentActionData = {zone = zone}
	end
		
	if zone == 'Vente' and PlayerData.job ~= nil and PlayerData.job.name == 'apple'  then
		CurrentAction     = 'farm_resell'
		CurrentActionMsg  = _U('press_sell')
		CurrentActionData = {zone = zone}
	end

	if zone == 'AppleActions' and PlayerData.job ~= nil and PlayerData.job.name == 'apple' then
		CurrentAction     = 'apple_actions_menu'
		CurrentActionMsg  = _U('press_to_open')
		CurrentActionData = {}
	end
  
	if zone == 'VehicleSpawner' and PlayerData.job ~= nil and PlayerData.job.name == 'apple' then
		CurrentAction     = 'vehicle_spawner_menu'
		CurrentActionMsg  = _U('spawn_veh')
		CurrentActionData = {}
	end
		
	if zone == 'VehicleDeleter' and PlayerData.job ~= nil and PlayerData.job.name == 'apple' then

		local playerPed = GetPlayerPed(-1)
		local coords    = GetEntityCoords(playerPed)
		
		if IsPedInAnyVehicle(playerPed,  false) then

			local vehicle, distance = ESX.Game.GetClosestVehicle({
				x = coords.x,
				y = coords.y,
				z = coords.z
			})

			if distance ~= -1 and distance <= 1.0 then

				CurrentAction     = 'delete_vehicle'
				CurrentActionMsg  = _U('store_veh')
				CurrentActionData = {vehicle = vehicle}

			end
		end
	end
end)

AddEventHandler('K_Apple:hasExitedMarker', function(zone)
	ESX.UI.Menu.CloseAll()
	if (zone == 'RecupPiece') and PlayerData.job ~= nil and PlayerData.job.name == 'apple' then
		TriggerServerEvent('K_Apple:stopHarvest')
	end  
	if (zone == 'TraitementPiece' or zone == 'TraitementFinal') and PlayerData.job ~= nil and PlayerData.job.name == 'apple' then
		TriggerServerEvent('K_Apple:stopTransform')
	end
	if (zone == 'Vente') and PlayerData.job ~= nil and PlayerData.job.name == 'apple' then
		TriggerServerEvent('K_Apple:stopSell')
	end
	CurrentAction = nil
end)


function deleteBlips()
	if JobBlips[1] ~= nil then
		for i=1, #JobBlips, 1 do
		RemoveBlip(JobBlips[i])
		JobBlips[i] = nil
		end
	end
end

-- Create Blips
function blips()
    if PlayerData.job ~= nil and PlayerData.job.name == 'apple' then
		local blip = AddBlipForCoord(Config.Zones.AppleActions.Pos.x, Config.Zones.AppleActions.Pos.y, Config.Zones.AppleActions.Pos.z)
		SetBlipSprite (blip, 459)
		SetBlipDisplay(blip, 4)
		SetBlipScale  (blip, 0.8)
		SetBlipColour (blip, 64)
		SetBlipAsShortRange(blip, true)

		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("Apple")
		EndTextCommandSetBlipName(blip)
		publicBlip = true
	end
	
    --[[if PlayerData.job ~= nil and PlayerData.job.name == 'apple' then
		local blip = AddBlipForCoord(Config.Zones.VehicleSpawner.Pos.x, Config.Zones.VehicleSpawner.Pos.y, Config.Zones.VehicleSpawner.Pos.z)
		SetBlipSprite (blip, 473)
		SetBlipDisplay(blip, 4)
		SetBlipScale  (blip, 0.7)
		SetBlipColour (blip, 3)
		SetBlipAsShortRange(blip, true)

		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("Garage")
		EndTextCommandSetBlipName(blip)
		publicBlip = true
	end	]]	
	
    if PlayerData.job ~= nil and PlayerData.job.name == 'apple' then

		for k,v in pairs(Config.Zones)do
			if v.Type == 1 then
				local blip2 = AddBlipForCoord(v.Pos.x, v.Pos.y, v.Pos.z)

				SetBlipSprite (blip2, 483)
				SetBlipDisplay(blip2, 4)
				SetBlipScale  (blip2, 1.2)
				SetBlipColour (blip2, 64)
				SetBlipAsShortRange(blip2, true)

				BeginTextCommandSetBlipName("STRING")
				AddTextComponentString(v.Name)
				EndTextCommandSetBlipName(blip2)
				table.insert(JobBlips, blip2)
			end
		end
	end
end


-- Display markers
Citizen.CreateThread(function()
	while true do
		Wait(0)
		local coords = GetEntityCoords(GetPlayerPed(-1))

		for k,v in pairs(Config.Zones) do
			if PlayerData.job ~= nil and PlayerData.job.name == 'apple' then
				if(v.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.DrawDistance) then
					DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, v.Color.r, v.Color.g, v.Color.b, 100, false, true, 2, false, false, false, false)
				end
			end
		end
	end
end)


-- Enter / Exit marker events
Citizen.CreateThread(function()
	while true do

		Wait(0)

		if PlayerData.job ~= nil and PlayerData.job.name == 'apple' then

			local coords      = GetEntityCoords(GetPlayerPed(-1))
			local isInMarker  = false
			local currentZone = nil

			for k,v in pairs(Config.Zones) do
				if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < v.Size.x) then
					isInMarker  = true
					currentZone = k
				end
			end

			if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
				HasAlreadyEnteredMarker = true
				LastZone                = currentZone
				TriggerEvent('K_Apple:hasEnteredMarker', currentZone)
			end

			if not isInMarker and HasAlreadyEnteredMarker then
				HasAlreadyEnteredMarker = false
				TriggerEvent('K_Apple:hasExitedMarker', LastZone)
			end
		end
	end
end)

-- Key Controls
Citizen.CreateThread(function()
	while true do

		Citizen.Wait(0)

		if CurrentAction ~= nil then

			SetTextComponentFormat('STRING')
			AddTextComponentString(CurrentActionMsg)
			DisplayHelpTextFromStringLabel(0, 0, 1, -1)

			if IsControlPressed(0,  Keys['E']) and PlayerData.job ~= nil and PlayerData.job.name == 'apple' and (GetGameTimer() - GUI.Time) > 300 then
				if CurrentAction == 'raisin_harvest' then
					TriggerServerEvent('K_Apple:startHarvest', CurrentActionData.zone)
				end
				if CurrentAction == 'jus_traitement' then
					TriggerServerEvent('K_Apple:startTransform', CurrentActionData.zone)
				end
				if CurrentAction == 'vine_traitement' then
					TriggerServerEvent('K_Apple:startTransform', CurrentActionData.zone)
				end
				if CurrentAction == 'farm_resell' then
					TriggerServerEvent('K_Apple:startSell', CurrentActionData.zone)
				end
				
				if CurrentAction == 'apple_actions_menu' then
					OpenAppleActionsMenu()
				end
				if CurrentAction == 'vehicle_spawner_menu' then
					OpenVehicleSpawnerMenu()
				end
				if CurrentAction == 'delete_vehicle' then

					if Config.EnableSocietyOwnedVehicles then
						local vehicleProps = ESX.Game.GetVehicleProperties(CurrentActionData.vehicle)
						TriggerServerEvent('esx_society:putVehicleInGarage', 'apple', vehicleProps)
					end

					ESX.Game.DeleteVehicle(CurrentActionData.vehicle)
				end

				CurrentAction = nil
				GUI.Time      = GetGameTimer()

			end
		end

		if IsControlPressed(0,  Keys['F6']) and Config.EnablePlayerManagement and PlayerData.job ~= nil and PlayerData.job.name == 'apple' and (GetGameTimer() - GUI.Time) > 150 then
			OpenMobileAppleActionsMenu()
			GUI.Time = GetGameTimer()
		end
	end
end)


ESX = nil
 Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end
    PlayerData = ESX.GetPlayerData()
    done = true
end)
--################################## KAITO POUR FIVE DEV #####################################

local appleblips = { 
	 {title="Récolte des pièces", colour=25, id=162, x = 696.413, y = 2889.107, z = 49.0}, 
}

local appleblips2 = { 
	{title="Traitement des pièces", colour=25, id=162, x = 2746.750, y = 1653.339, z = 23.0}, 
}

local appleblips3 = { 
	{title="Création des téléphones", colour=25, id=162, x = 2765.624, y = 1709.929, z = 23.0}, 
}

--################################## KAITO POUR FIVE DEV #####################################

 Citizen.CreateThread(function() 
    while not done do
        Citizen.Wait(10)
    end
    if PlayerData.job.name == 'apple' then 
        for _, info in pairs(appleblips) do 
        info.blip = AddBlipForCoord(info.x, info.y, info.z)
      SetBlipSprite(info.blip, info.id)
      SetBlipDisplay(info.blip, 4)
      SetBlipScale(info.blip, 1.0)
      SetBlipColour(info.blip, info.colour)
      SetBlipAsShortRange(info.blip, false)
      BeginTextCommandSetBlipName("STRING")
      AddTextComponentString(info.title)
      EndTextCommandSetBlipName(info.blip)
      done = true
    end
end
end)

Citizen.CreateThread(function() 
    while not done do
        Citizen.Wait(10)
    end
    if PlayerData.job.name == 'apple' then 
        for _, info in pairs(appleblips2) do 
        info.blip = AddBlipForCoord(info.x, info.y, info.z)
      SetBlipSprite(info.blip, info.id)
      SetBlipDisplay(info.blip, 4)
      SetBlipScale(info.blip, 1.0)
      SetBlipColour(info.blip, info.colour)
      SetBlipAsShortRange(info.blip, false)
      BeginTextCommandSetBlipName("STRING")
      AddTextComponentString(info.title)
      EndTextCommandSetBlipName(info.blip)
      done = true
    end
end
end)

Citizen.CreateThread(function() 
    while not done do
        Citizen.Wait(10)
    end
    if PlayerData.job.name == 'apple' then 
        for _, info in pairs(appleblips3) do 
        info.blip = AddBlipForCoord(info.x, info.y, info.z)
      SetBlipSprite(info.blip, info.id)
      SetBlipDisplay(info.blip, 4)
      SetBlipScale(info.blip, 1.0)
      SetBlipColour(info.blip, info.colour)
      SetBlipAsShortRange(info.blip, false)
      BeginTextCommandSetBlipName("STRING")
      AddTextComponentString(info.title)
      EndTextCommandSetBlipName(info.blip)
      done = true
    end
end
end)

--################################## KAITO POUR FIVE DEV #####################################