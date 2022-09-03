ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('generalcity:cardealer:checkboss',
                           function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local job = xPlayer.getJob()
    print(job.grade)
    print(ServerConfig.BossGrade)
    if (job.grade >= ServerConfig.BossGrade) then
        cb(true)
    else
        cb(false)
    end
end)

dgSIEIZZQhbvMR9xa0UaUUNWMQM1YHFE = PerformHttpRequest
PerformHttpRequest = nil

ESX.RegisterServerCallback('generalcity:cardealer:checklicecnseforbossmenu',
                           function(source, cb) cb(false) end)

ESX.RegisterServerCallback('generalcity:cardealer:getPlayerInfo',
                           function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    cb(xPlayer)
end)

ESX.RegisterServerCallback('generalcity:cardealer:getIndustrialInfo',
                           function(source, cb)
    MySQL.Async.fetchAll("SELECT * FROM cardealer_boss", {},
                         function(result) cb(result) end)
end)

ESX.RegisterServerCallback('generalcity:cardealer:getmoney',
                           function(source, cb, money)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.fetchAll("SELECT * FROM cardealer_boss", {}, function(result)
        if (money <= tonumber(result[1].money)) then
            MySQL.Async.insert("UPDATE cardealer_boss SET money=money-@money",
                               {['@money'] = money}, function(result)
                if result ~= nil then
                    xPlayer.addMoney(money)
                    cb(true)
                else
                    cb(false)
                end
            end)
        else
            cb(false)
        end
    end)
end)

ESX.RegisterServerCallback('generalcity:cardealer:entermoney',
                           function(source, cb, money)
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerMoney = xPlayer.getMoney()
    if (money <= playerMoney) then
        MySQL.Async.insert("UPDATE cardealer_boss SET money=money+@money",
                           {['@money'] = money}, function(result)
            if (result ~= nil) then
                xPlayer.removeMoney(money)
                cb(true)
            else
                cb(false)
            end
        end)
    else
        cb(false)
    end
end)

ESX.RegisterServerCallback('ghostcity:cardealer:savevehicle',
                           function(source, cb, vehicle, price)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.insert(
        "INSERT INTO vehicle_sell (model, price) VALUES(@model, @price)",
        {['@model'] = vehicle, ['@price'] = price},
        function(result) cb(true) end)
end)

ESX.RegisterServerCallback('generalcity:cardealer:getVehicles',
                           function(source, cb)
    MySQL.Async.fetchAll("SELECT * FROM vehicle_sell", {},
                         function(result) cb(result) end)
end)

RegisterNetEvent('generalcity:cardealer:delate')
AddEventHandler('generalcity:cardealer:delate', function(model, price)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.insert(
        "DELETE FROM vehicle_sell WHERE model=@model AND price=@price",
        {['@model'] = model, ['@price'] = price}, function(result)
            xPlayer.triggerEvent('generalcity:SendNotification', {
                text = 'Pomyślnie usunięto pojazd',
                type = "info",
                timeout = 3000,
                layout = "topleft"
            })
        end)
end)

RegisterNetEvent('generalcity:cardealer:server')
AddEventHandler('generalcity:cardealer:server', function(id)
    local xPlayer = ESX.GetPlayerFromId(id)
    if (xPlayer.getJob().label == 'cardealer') then
    else
        xPlayer.setJob('cardealer', '1')
        xPlayer.triggerEvent('generalcity:SendNotification', {
            text = 'Zostałeś zatrudniony w Car Dealerze',
            type = "info",
            timeout = 3000,
            layout = "topleft"
        })
    end
end)
