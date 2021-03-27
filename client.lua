function notification(msg)
	SetNotificationTextEntry('STRING')
	AddTextComponentSubstringPlayerName(msg)
	DrawNotification(false, true)
end


AddEventHandler('playerSpawned', function()
	TriggerServerEvent('rgz_playtime:loggedIn', GetPlayerName(PlayerId()))
end)

RegisterCommand('time1', function(source)
	TriggerServerEvent('rgz_playtime:loggedIn', GetPlayerName(PlayerId()))
end, false)

RegisterNetEvent('rgz_playtime:notif')
AddEventHandler('rgz_playtime:notif', function(msg)
    notification(msg)
end)