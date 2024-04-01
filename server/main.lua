ESX = exports["es_extended"]:getSharedObject()


RegisterCommand('delcarplate', function(source, args) -- TODO 
	if havePermission(source) then
		if args[1] == nil then
			TriggerClientEvent('esx:showNotification', source, '/delcarplate <plate>')
		else
			local plate = args[1]
			if #args > 1 then
				for i=2, #args do
					plate = plate.." "..args[i]
				end		
			end
			plate = string.upper(plate)
			
			local result = MySQL.Sync.execute('DELETE FROM owned_vehicles WHERE plate = @plate', {
				['@plate'] = plate
			})
			if result == 1 then
				TriggerClientEvent('esx:showNotification', source, _U('del_car', plate))
			elseif result == 0 then
				TriggerClientEvent('esx:showNotification', source, _U('del_car_error', plate))
			end		
		end
	else
		TriggerClientEvent('esx:showNotification', source, 'Jus negalite naudoti šios komandos')
	end		
end)

--functions--

RegisterCommand("givecar", function(source, args, rawCommand)
	if havePermission(source) then
        TriggerClientEvent('givecar:menu', source)
    else
        TriggerClientEvent('esx:showNotification', source, 'Jus negalite naudoti šios komandos')
    end
end)

RegisterServerEvent('esx_giveownedcar:setVehicle')
AddEventHandler('esx_giveownedcar:setVehicle', function(vehicleProps, playerID, vehicleType)
    local _source = playerID
    local xPlayer = ESX.GetPlayerFromId(_source)

    MySQL.Async.execute('INSERT INTO owned_vehicles (owner, plate, vehicle, stored, type) VALUES (@owner, @plate, @vehicle, @stored, @type)',
    {
        ['@owner']   = xPlayer.identifier,
        ['@plate']   = vehicleProps.plate,
        ['@vehicle'] = json.encode(vehicleProps),
        ['@stored']  = 1,
        ['type']     = vehicleType
    }, function()
        if Config.ReceiveMsg then
            TriggerClientEvent('esx:showNotification', _source, 'Gavote transportą su numeriais: ' .. string.upper(vehicleProps.plate))
        end
    end)
end)

RegisterServerEvent('esx_giveownedcar:setVehicleFullTune')
AddEventHandler('esx_giveownedcar:setVehicleFullTune', function(vehicleProps, playerID, vehicleType)
    local _source = playerID
    local xPlayer = ESX.GetPlayerFromId(_source)

    vehicleProps.modEngine = 3 
    vehicleProps.modBrakes = 2 
    vehicleProps.modTransmission = 2 
    vehicleProps.modSuspension = 3 
    vehicleProps.modTurbo = true 
    vehicleProps.windowTint = 2

    MySQL.Async.execute('INSERT INTO owned_vehicles (owner, plate, vehicle, stored, type) VALUES (@owner, @plate, @vehicle, @stored, @type)',
    {
        ['@owner'] = xPlayer.identifier,
        ['@plate'] = vehicleProps.plate,
        ['@vehicle'] = json.encode(vehicleProps), 
        ['@stored'] = 1,
        ['type'] = vehicleType
    }, function(rowsChanged)
        if Config.ReceiveMsg then
            TriggerClientEvent('esx:showNotification', _source, 'Gavote transporto su pilnomis modifikacijomis ir numeriais: ' .. string.upper(vehicleProps.plate))
        end	
    end)
end)


function havePermission(_source)
	local xPlayer = ESX.GetPlayerFromId(_source)
	local playerGroup = xPlayer.getGroup()
	local isAdmin = false
	for k,v in pairs(Config.AuthorizedRanks) do
		if v == playerGroup then
			isAdmin = true
			break
		end
	end
	if IsPlayerAceAllowed(_source, "giveownedcar.command") then isAdmin = true end
	return isAdmin
end



function givevehicle(input, vehicleType)
    local _source = source
    if havePermission(_source) then
        local vehicleSpawnCode = input[1] 
        local playerId = tonumber(input[2]) 
        local tuning = input[3] 
        local plates = input[4] 

		-- PLATE --
        local function generateRandomPlate()
            local chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
            local length = 8
            local randomPlate = ''
            for i = 1, length do
                local rand = math.random(#chars)
                randomPlate = randomPlate .. chars:sub(rand, rand)
            end
            return randomPlate
        end

        if not vehicleSpawnCode or not playerId then
            TriggerClientEvent('esx:showNotification', _source, 'Netinkamas kodas arba ID')
            return
        end

        local playerName = GetPlayerName(playerId)
        if plates == nil or plates == '' then
            plates = generateRandomPlate()
        else
            for i = 5, #input do
                plates = plates.." "..input[i]
            end
            plates = string.upper(plates)
        end

		if tostring(tuning) == 'true' then
			TriggerClientEvent('esx_giveownedcar:spawnVehicle', _source, playerId, vehicleSpawnCode, plates, playerName, 'player', vehicleType, true)
        else
			TriggerClientEvent('esx_giveownedcar:spawnVehicle', _source, playerId, vehicleSpawnCode, plates, playerName, 'player', vehicleType, false)
        end
    else
        TriggerClientEvent('esx:showNotification', _source, 'Jūs negalite naudoti šios komandos!')
    end
end




RegisterServerEvent('ServerGiveVehicle')
AddEventHandler('ServerGiveVehicle', function(input)
    givevehicle(input, 'car')
end)