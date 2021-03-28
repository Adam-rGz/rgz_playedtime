

local playersData = {}
local playersDataLogged = {}
local playersDataActuall = {}



MySQL.ready(function()
    print('eoeoeo')
    MySQL.Async.fetchAll('SELECT * FROM playtime', {}, function(result)	
        for i=1, #result, 1 do
			-- result[i].identifier 
			-- result[i].time 
			-- result[i].login 
            playersData[result[i].identifier] = result[i].time
            playersDataLogged[result[i].identifier] = result[i].login

		end
    end)
end)


function SecondsToClock(seconds)
    if seconds ~= nil then
        local seconds = tonumber(seconds)

        if seconds <= 0 then
            return "00:00:00";
        else
            hours = string.format("%02.f", math.floor(seconds/3600));
            mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
            secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
            return hours..":"..mins..":"..secs
        end
    end
end



function dropPlayer(source)
    local identifier = GetPlayerIdentifiers(source)[1]
    local actuallTime = os.time()
    local name = GetPlayerName(source)
    if(playersData[identifier] ~= nil and playersDataActuall[identifier] ~= nil) then
        local time = tonumber(actuallTime - playersDataActuall[identifier])
        local timeFormatted = SecondsToClock(time)
        local timeAll = time + playersData[identifier]
        local timeAllFormatted = SecondsToClock(timeAll)

        local message = '`'..name..'` ['..identifier..']\n Session time: `'..timeFormatted..'`\n'..'Total time: `'..timeAllFormatted..'`'
        sendToDiscord('Player left', message)
        MySQL.Async.execute('UPDATE playtime SET time = @time WHERE identifier = @identifier',
            {['time'] = timeAll, ['identifier'] = identifier},
            function(affectedRows)
            --   print('Updated login')
            end
        )
        playersData[identifier] = timeAll
    else
        --print('rgz_playtime didnt recognize player')
    end
end


function sendToDiscord(name, message, footer)
    if Config.WebhookLink ~= '' then
        local embed = {
                {
                    ["color"] = 2067276,
                    ["title"] =  name,
                    ["description"] = message,
                }
            }

        PerformHttpRequest(Config.WebhookLink, function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
    else
        print('^1[rgz_playtime] Error:^0 Config.WebhookLink is empty!')
    end
end


AddEventHandler('playerDropped', function(reason)    
	dropPlayer(source, reason)
end)


RegisterNetEvent('rgz_playtime:loggedIn')
AddEventHandler('rgz_playtime:loggedIn', function(playerName)
	local _source = source	
    local _playerName = playerName
    local identifier = GetPlayerIdentifiers(_source)[1]
    local actuallTime = os.time()
   
    if playersData[identifier] ~= nil then
        playersDataActuall[identifier] = actuallTime
        playersDataLogged[identifier] = playersDataLogged[identifier] + 1
        local totaltimeFormatted = SecondsToClock(playersData[identifier])
        MySQL.Async.execute('UPDATE playtime SET login = login + 1 WHERE identifier = @identifier',
            {['identifier'] = identifier},
            function(affectedRows)
            --   print('Updated login')
            end
        )
        TriggerClientEvent('rgz_playtime:notif', _source, Config.Strings['welcome']..'\n'..Config.Strings['ptotaltime']..'~b~'.. totaltimeFormatted ..'~s~\n'..string.format(Config.Strings['loggedin'], playersDataLogged[identifier]))
    else        
        playersDataActuall[identifier] = actuallTime
        playersData[identifier] = 0
        MySQL.Async.execute('INSERT INTO playtime (identifier, time, login) VALUES (@identifier, @time, @login)',
            { ['identifier'] = identifier, ['time'] = 0, ['login'] = 0},
            function(affectedRows)
            --   print(affectedRows)
            end
        )
        
        
        TriggerClientEvent('rgz_playtime:notif', _source, Config.Strings['welcome1st'])
    end
end)


RegisterCommand('time2', function(source)
	dropPlayer(source)
end, false)



