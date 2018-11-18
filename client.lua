local isFrozen = false;

RegisterNetEvent('alogin:togFreeze')
AddEventHandler('alogin:togFreeze', function()
    isFrozen = not isFrozen
end)

Citizen.CreateThread(function()
    while true do
        FreezeEntityPosition(GetPlayerPed(-1), isFrozen)
		if isFrozen then DisableControlAction(0, 311, true) end
        Citizen.Wait(0)
    end
end)