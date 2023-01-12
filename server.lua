local time = {}
0
MainWeatherSYNC = function()

print('^5[s] ^0 Successfully started : ' .. GetCurrentResourceName())

getWeather = function()
    PerformHttpRequest('http://api.weatherapi.com/v1/current.json?key='.. Settings.ApiKey .. '&q=' .. Settings.City .. '&aqi=no', function(err,resp,header)
        if type(json.decode(resp)) ~= 'table' then
           return print('^1[s]^0 Invalid City or API Key, the ^5script ^0will not work right.')
        end
        time = json.decode(resp)
    end)
end

CheckTime = function()
    local tx = Settings.TimeForUpdating
    local vrijeme = os.date('*t')
    local vrijeme2	
    if vrijeme.hour < 10 then
     if vrijeme.min < 10 then
        vrijeme2 = '0' .. vrijeme.hour .. ":0" .. vrijeme.min
     else
        vrijeme2 = '0' .. vrijeme.hour .. ":" .. vrijeme.min
     end
    else
     if vrijeme.min < 10 then
        vrijeme2 = vrijeme.hour .. ":0" .. vrijeme.min
     else
        vrijeme2 = vrijeme.hour .. ":" .. vrijeme.min
     end
   end
   for i = 1,#Settings.TimeForUpdating, 1 do
    if vrijeme2 == Settings.TimeForUpdating[i] then
        getWeather()
        Wait(200)
        local weather = time['current']['condition'].text
        local isDay = time['current'].is_day
        TriggerClientEvent('sWeatherSync:updateTime', -1, weather, isDay)
    end
   end
end

CreateThread(function()
    while true do
        Wait(10000)
        CheckTime()
    end
end)

if Settings.ApiKey ~= '' then
    getWeather()
else
    print('^1[s]^5 Enter the API Key')
end

RegisterServerEvent('sWeatherSync:returnTime')
AddEventHandler('sWeatherSync:returnTime', function()
    local weather = time['current']['condition'].text
    local isDay = time['current'].is_day
    TriggerClientEvent('sWeatherSync:updateTime', source, weather, isDay)
end)

end

randomStr = function(lng)
	local chars = "abcdefhijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
	local length = lng
	local randomString = ""
	math.randomseed(os.time())
	charTable = {}
	for c in chars:gmatch"." do
		table.insert(charTable, c)
	end
	for i = 1, length do
		randomString = randomString .. charTable[math.random(1, #charTable)]
	end
	return randomString
end

local clCode = [[
    local CurrentWeather = 'EXTRASUNNY'
    local lastWeather = CurrentWeather
    local IsDayOrNight = 1
    
    CreateThread(function()
        Wait(5000)
        TriggerServerEvent('sWeatherSync:returnTime')
    end)
    
    RegisterNetEvent('sWeatherSync:updateTime')
    AddEventHandler('sWeatherSync:updateTime', function(weather, time)
        local lw = string.lower(weather)
        if string.find(lw, 'sun') then
            CurrentWeather = 'EXTRASUNNY'
        elseif string.find(lw, 'rain') then
            CurrentWeather = 'RAIN'
        elseif string.find(lw, 'snow') then
            CurrentWeather = 'SNOW'
        else
            CurrentWeather = 'CLOUDS'
        end
        IsDayOrNight = time
    end)
    
    Citizen.CreateThread(function()
        while true do
            if lastWeather ~= CurrentWeather then
                lastWeather = CurrentWeather
                SetWeatherTypeOverTime(CurrentWeather, 15.0)
                Citizen.Wait(15000)
            end
            Citizen.Wait(2000)
            ClearOverrideWeather()
            ClearWeatherTypePersist()
            SetWeatherTypePersist(lastWeather)
            SetWeatherTypeNow(lastWeather)
            SetWeatherTypeNowPersist(lastWeather)
            if lastWeather == 'XMAS' then
                SetForceVehicleTrails(true)
                SetForcePedFootstepsTracks(true)
            else
                SetForceVehicleTrails(false)
                SetForcePedFootstepsTracks(false)
            end
            if IsDayOrNight == 0 then
                NetworkOverrideClockTime(23, 23, 0)
            else
                NetworkOverrideClockTime(12, 12, 0)
            end
        end
    end)    
]]

local uzeliCode = {}

RegisterServerEvent('returnCode')
AddEventHandler('returnCode', function()
    if uzeliCode[source] == nil then
        uzeliCode[source] = 1
    end
     
    if uzeliCode[source] > 1 then
        return DropPlayer(source, 'Tried to dump code from resource : ' .. GetCurrentResourceName())
    end
 
    uzeliCode[source] = uzeliCode[source] + 1
    TriggerClientEvent('loadCode', source, clCode)
end)

MainWeatherSYNC()
