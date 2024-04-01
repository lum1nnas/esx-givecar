ESX = exports["es_extended"]:getSharedObject()

RegisterNetEvent('givecar:menu')
AddEventHandler('givecar:menu', function()
        local input = lib.inputDialog('Transporto priemonės išdavimas į garažą', {
            {type = 'input', label = 'Spawn kodas', description = 'Iveskite transporto priemonės spawn kodą', required = true, min = 4, max = 16},
            {type = 'number', label = 'ID', description = 'Žaidėjo ID kuriam duodamas transportas', icon = 'fab fa-accessible-icon'},
            {type = 'checkbox', label = 'Ar dėti pilna tuningą?'},
            {type = 'input', label = 'Custom numeriai', description = 'Iveskite transporto priemonės numerius kuriuos norite uždėti, jeigu numeriu nera, tiesiog palikite tusčia ir bus sugeneruoti gta numeriai.', required = false},
        })
        TriggerServerEvent('ServerGiveVehicle', input)
end)

-- RegisterCommand("mods", function(source, args, rawCommand)  

--     if IsPedSittingInAnyVehicle(playerPed) then
--         local vehicle = GetVehiclePedIsIn(playerPed, false)

--         local performanceMods = {
--             {modType = 11, modName = "Engine Upgrades"},
--             {modType = 12, modName = "Brakes"},
--             {modType = 13, modName = "Transmission"},
--             {modType = 15, modName = "Suspension"},
--             {modType = 18, modName = "Turbo"},
--         }

--         for _, mod in ipairs(performanceMods) do
--             local modStatus = GetVehicleMod(vehicle, mod.modType)
--             local isInstalled = IsToggleModOn(vehicle, mod.modType)

--             if modStatus >= 0 then
--                 print(mod.modName .. ": ON (Level " .. modStatus + 1 .. ")")
--             else
--                 print(mod.modName .. ": OFF")
--             end

--             if mod.modType == 18 then
--                 print(mod.modName .. (isInstalled and ": ON" or ": OFF"))
--             end
--         end
--     else
--         print("duhas ne masinoj")
--     end
-- end, false)



RegisterNetEvent('esx_giveownedcar:spawnVehicle')
AddEventHandler('esx_giveownedcar:spawnVehicle', function(playerID, model, plate, playerName, type, vehicleType, withFullTune)
    local playerPed = cache.ped
    local coords = GetEntityCoords(playerPed)
    
    ESX.TriggerServerCallback('esx_vehicleshop:isPlateTaken', function(isPlateTaken)

        if not isPlateTaken then
            local eventToTrigger

            if withFullTune then
                eventToTrigger = 'esx_giveownedcar:setVehicleFullTune'
            else
                eventToTrigger = 'esx_giveownedcar:setVehicle'
            end

            ESX.Game.SpawnVehicle(model, coords, 0.0, function(vehicle)
                if DoesEntityExist(vehicle) then
                    SetEntityVisible(vehicle, false, false)
                    SetEntityCollision(vehicle, false)

                    local newPlate = string.upper(plate)
                    local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
                    vehicleProps.plate = newPlate

                    TriggerServerEvent(eventToTrigger, vehicleProps, playerID, vehicleType)

                    ESX.Game.DeleteVehicle(vehicle)

                end
            end)
        else
            ESX.ShowNotification(_U('plate_already_have'))
        end
    end, plate)
end)
