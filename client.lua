ESX = nil
Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
    while ESX.PlayerData.job == nil do Citizen.Wait(10) end
end)

exports.qtarget:RemoveZone('CarDealer1')
exports.qtarget:RemoveZone('CarDealer2')
exports.qtarget:AddBoxZone("CarDealer1", vector3(-30.41, -1105.87, 26.42), 2, 3,
                           {
    name = "CarDealer1",
    heading = 310,
    debugPoly = false,
    minZ = 24.77834,
    maxZ = 28.87834
}, {
    options = {
        {
            event = "generalcity:openbossmenu:cardealer",
            icon = "fas fa-briefcase",
            label = "Sprawdź dokumenty Szefostwa",
            job = "cardealer"
        }
    },
    distance = 3.5
})
exports.qtarget:AddBoxZone('CarDealer2', vector3(-56.37, -1097.99, 26.42), 5, 3,
                           {
    name = "CarDealer2",
    heading = 310,
    debugPoly = false,
    minZ = 24,
    maxZ = 28
}, {
    options = {
        {
            event = "generalcity:open:offert",
            icon = "fas fa-car-side",
            label = "Sprawdź Oferte Używanych Aut"
        }
    },
    distance = 2.5
})

RegisterNetEvent('generalcity:openbossmenu:cardealer')
AddEventHandler('generalcity:openbossmenu:cardealer', function()
    ESX.TriggerServerCallback('generalcity:cardealer:checkboss', function(cb)
        if cb then
            ESX.TriggerServerCallback(
                'generalcity:cardealer:checklicecnseforbossmenu', function(cb)
                    if cb then
                        ESX.TriggerServerCallback(
                            'generalcity:cardealer:getPlayerInfo', function(cb)
                                SendNUIMessage(
                                    {action = "open", playerData = cb})
                            end)
                    else
                        print('boss menu')
                        OpenBossMenu()
                    end
                end)
        else
            print('nope')
            TriggerEvent("generalcity:SendNotification", {
                text = 'Ej co robisz? Jak ci się nudzi to posprzątaj podłoge',
                type = "info",
                timeout = 3000,
                layout = "topleft"
            })
        end
    end)
end)

function OpenBossMenu()
    ESX.TriggerServerCallback('generalcity:cardealer:checkboss', function(cb)
        if cb then
            ESX.TriggerServerCallback('generalcity:cardealer:getIndustrialInfo',
                                      function(cb)
                ESX.UI.Menu.CloseAll()
                ESX.UI.Menu.Open('default', GetCurrentResourceName(),
                                 'funny_boss_cardealer_menu', {
                    title = "Papiery Szefostwa",
                    align = "center",
                    elements = {
                        {label = "$ " .. cb[1].money, value = "nil"},
                        {label = "Wypłać Pieniądze", value = "get"},
                        {label = "Wpłać Pieniądze", value = "enter"},
                        {label = "Zatrudnij Gracza", value = "getJob"}
                    }
                }, function(data, menu)
                    if (data.current.value == 'get') then
                        OpenDialogMenuGetMoney()
                    end
                    if (data.current.value == 'enter') then
                        OpenDialogMenuEnterMoney()
                    end
                    if (data.current.value == 'getJob') then
                        OpenDialogMenuEnterPlayerID()
                    end
                    print(data.current.value)
                end, function(data, menu) menu.close() end)
            end)
        else
            TriggerEvent("generalcity:SendNotification", {
                text = 'Ej co robisz? Jak ci się nudzi to posprzątaj podłoge',
                type = "info",
                timeout = 3000,
                layout = "topleft"
            })
        end
    end)
end

function OpenDialogMenuEnterPlayerID()
    ESX.UI.Menu.CloseAll()
    ESX.UI.Menu.Open('dialog', GetCurrentResourceName(),
                     'funny_playerId_cardealer, menu',
                     {title = "Wpisz ID Gracza", align = "center"},
                     function(data, menu)
        TriggerServerEvent('generalcity:cardealer:server', data.value)
    end, function(data, menu) menu.close() end)
end

function OpenDialogMenuEnterMoney()
    ESX.TriggerServerCallback('generalcity:cardealer:checkboss', function(cb)
        if cb then
            ESX.UI.Menu.CloseAll()
            ESX.UI.Menu.Open('dialog', GetCurrentResourceName(),
                             'funny_dialog_menu', {
                title = "Wpisz Ilość pieniędzy",
                align = "center"
            }, function(data, menu)
                ESX.TriggerServerCallback(
                    'generalcity:cardealer:getIndustrialInfo', function(cb)
                        menu.close()
                        ESX.TriggerServerCallback(
                            'generalcity:cardealer:entermoney', function(cb)
                                if cb then
                                    TriggerEvent("generalcity:SendNotification",
                                                 {
                                        text = 'Pomyślnie wpłacono ' ..
                                            data.value .. '$',
                                        type = "info",
                                        timeout = 3000,
                                        layout = "topleft"
                                    })
                                else
                                    TriggerEvent("generalcity:SendNotification",
                                                 {
                                        text = 'Nie posiadasz wystarczająco pieniędzy',
                                        type = "info",
                                        timeout = 3000,
                                        layout = "topleft"
                                    })
                                end
                            end, data.value)
                    end)
            end, function(data, menu) menu.close() end)
        else
            TriggerEvent("generalcity:SendNotification", {
                text = 'Ej co robisz? Jak ci się nudzi to posprzątaj podłoge',
                type = "info",
                timeout = 3000,
                layout = "topleft"
            })
        end
    end)
end

function OpenDialogMenuGetMoney()
    ESX.TriggerServerCallback('generalcity:cardealer:checkboss', function(cb)
        if cb then
            ESX.UI.Menu.CloseAll()
            ESX.UI.Menu.Open('dialog', GetCurrentResourceName(),
                             'funny_dialog_menu', {
                title = "Wpisz Ilość pieniędzy",
                align = "center"
            }, function(data, menu)
                ESX.TriggerServerCallback(
                    'generalcity:cardealer:getIndustrialInfo', function(cb)
                        menu.close()
                        ESX.TriggerServerCallback(
                            'generalcity:cardealer:getmoney', function(cb)
                                if cb then
                                    TriggerEvent("generalcity:SendNotification",
                                                 {
                                        text = 'Pomyślnie wypłacono ' ..
                                            data.value .. '$',
                                        type = "info",
                                        timeout = 3000,
                                        layout = "topleft"
                                    })
                                else
                                    TriggerEvent("generalcity:SendNotification",
                                                 {
                                        text = 'Twoja Firma nie posiada wystarczająco pieniędzy',
                                        type = "info",
                                        timeout = 3000,
                                        layout = "topleft"
                                    })
                                end
                            end, data.value)
                    end)
            end, function(data, menu) menu.close() end)
        else
            TriggerEvent("generalcity:SendNotification", {
                text = 'Ej co robisz? Jak ci się nudzi to posprzątaj podłoge',
                type = "info",
                timeout = 3000,
                layout = "topleft"
            })
        end
    end)
end

AddEventHandler('onResourceStop', function(resourceName)
    if (resourceName == GetCurrentResourceName()) then
        ESX.UI.Menu.CloseAll()
        RemoveBlip()
    end
end)

RegisterCommand('cardealer', function()
    if ESX.PlayerData.job.name == 'cardealer' then OpenCarDealerMenu() end

end)

function OpenCarDealerMenu()
    ESX.UI.Menu.CloseAll()
    local elements = {}
    local playerPed = PlayerPedId()
    if IsPedInAnyVehicle(playerPed, false) then
        table.insert(elements,
                     {label = "Wystawianie pojazdu", value = "vehicles"})
    end
    table.insert(elements, {label = "Zarządzanie pojazdami", value = "menage"})
    table.insert(elements, {label = "Pozyskaj nowy pojazd", value = "newcar"})
    ESX.UI.Menu.Open('default', GetCurrentResourceName(),
                     'funny_car_dealer_menu', {
        title = "Menu Car Dealera",
        align = "center",
        elements = elements
    }, function(data, menu)
        if data.current.value == 'vehicles' then
            local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
            OpenDialogPriceMenu(vehicle)
        end
        if data.current.value == 'newcar' then
            menu.close()
            OpenNewCar()
        end
        if data.current.value == 'menage' then OpenMenageMenu() end
    end, function(data, menu) menu.close() end)
end

local blips = {
    {
        title = "Nowe Auto",
        colour = 61,
        id = 523,
        x = 1207.4814,
        y = -3115.1760,
        z = 5.5440
    }
}

function OpenNewCar()
    TriggerEvent("generalcity:SendNotification", {
        text = 'Na mapie został zaznaczony GPS pojazdu!',
        type = "info",
        timeout = 3000,
        layout = "topleft"
    })
    Citizen.CreateThread(function()

        for _, info in pairs(blips) do
            info.blip = AddBlipForCoord(info.x, info.y, info.z)
            SetBlipSprite(info.blip, info.id)
            SetBlipDisplay(info.blip, 4)
            SetBlipScale(info.blip, 1.0)
            SetBlipColour(info.blip, info.colour)
            SetBlipAsShortRange(info.blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(info.title)
            EndTexdtCommandSetBlipName(info.blip)
            AddEventHandler('onResourceStop',
                            function() RemoveBlip(info.blip) end)
        end
    end)
    local table = ClientConfig.Cars
    local los1 = math.random(1, 2)
    local model = 'bmx'
    for v, k in pairs(table) do if v == los1 then model = k.model end end
    ESX.Game.SpawnVehicle(model, vector3(1204.5090, -3117.0122, 5.5403), 2.6243,
                          function()
        while true do
            if (GetDisplayNameFromVehicleModel(
                GetEntityModel(GetVehiclePedIsIn(PlayerPedId(), false))) ==
                model) then
                TriggerEvent("generalcity:SendNotification", {
                    text = 'Gratulacje! Teraz wystaw pojazd na sprzedaż!',
                    type = "info",
                    timeout = 3000,
                    layout = "topleft"
                })
            end
            Wait(0)
        end
    end)
end

function OpenMenageMenu()
    ESX.TriggerServerCallback('generalcity:cardealer:getVehicles', function(cb)
        local elements = {}
        for v, k in pairs(cb) do
            table.insert(elements, {
                label = "🚗| " .. k.model .. " | 💰 " .. k.price .. "$",
                value = k.model,
                price = k.price
            })
        end
        ESX.UI.Menu.CloseAll()
        ESX.UI.Menu.Open('default', GetCurrentResourceName(),
                         'funny_vehicle_sell_menu', {
            title = "Wybierz Pojazd",
            align = "center",
            elements = elements
        }, function(data, menu)
            OpenVehicleMenageMenu(data.current.value, data.current.price)
        end, function(data, menu) menu.close() end)
    end)
end

function OpenVehicleMenageMenu(model, price)
    ESX.UI.Menu.CloseAll()
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'funny_menage_menu',
                     {
        title = "Wybierz Akcje",
        align = "center",
        elements = {
            {label = "Wyjmij pojazd", value = 'get'},
            {label = "Usuń pojazd", value = "delate"}
        }
    }, function(data, menu)
        if data.current.value == 'get' then
            ESX.Game.SpawnVehicle(model, GetEntityCoords(PlayerPedId()),
                                  GetEntityHeading(PlayerPedId()), function()
                print('[INFO] Vehicle Spawned')
            end)
            TriggerEvent("generalcity:SendNotification", {
                text = 'Naciśnij Tab aby schować pojazd',
                type = "info",
                timeout = 3000,
                layout = "topleft"
            })
            RegisterCommand('cardealer:s', function()
                local vehcile = GetVehiclePedIsIn(PlayerPedId())
                ESX.Game.DeleteVehicle(vehicle)
            end)
            RegisterKeyMapping('cardealer:s', 'Chowanie pojazdu', 'keyboard',
                               'TAB')
        end
        if data.current.value == 'delate' then
            menu.close()
            TriggerServerEvent('generalcity:cardealer:delate', model, price)
        end
    end, function(data, menu) menu.close() end)
end

function OpenVehicleSellMenu()
    ESX.TriggerServerCallback('generalcity:cardealer:getVehicles', function(cb)
        local elements = {}
        for v, k in pairs(cb) do
            table.insert(elements, {
                label = "🚗| " .. k.model .. " | 💰 " .. k.price .. "$",
                value = k.model,
                price = k.price
            })
        end
        ESX.UI.Menu.CloseAll()
        ESX.UI.Menu.Open('default', GetCurrentResourceName(),
                         'funny_vehicle_sell_menu', {
            title = "Wybierz Pojazd",
            align = "center",
            elements = elements
        }, function(data, menu)
            SellVehicle(data.current.value, data.current.price)
        end, function(data, menu) menu.close() end)
    end)
end
function OpenDialogPriceMenu(vehicle)
    ESX.UI.Menu.CloseAll()
    ESX.UI.Menu.Open('dialog', GetCurrentResourceName(),
                     'funny_dialog_price_menu',
                     {title = "Wpisz cene", align = "center"},
                     function(data, menu)
        local price = data.value
        local vehicle2 = vehicle
        vehicle = GetEntityModel(vehicle)
        vehicle = GetDisplayNameFromVehicleModel(vehicle)
        ESX.TriggerServerCallback('ghostcity:cardealer:savevehicle',
                                  function(cb)
            if cb then
                menu.close()
                ESX.Game.DeleteVehicle(vehicle2)
                TriggerEvent("generalcity:SendNotification", {
                    text = 'Pomyślnie dodano pojazd',
                    type = "info",
                    timeout = 3000,
                    layout = "topleft"
                })
            else
                menu.close()
                TriggerEvent("generalcity:SendNotification", {
                    text = 'Coś poszło nie tak :/',
                    type = "info",
                    timeout = 3000,
                    layout = "topleft"
                })
            end
        end, vehicle, price)
    end, function(data, menu) menu.close() end)
end

function OpenOffertMenu()
    ESX.TriggerServerCallback('generalcity:cardealer:getVehicles', function(cb)
        local elements = {{label = "Lista Używanych Aut", value = "nil"}}
        for v, k in pairs(cb) do
            table.insert(elements, {
                label = "🚗| " .. k.model .. " | 💰 " .. k.price .. "$",
                value = k.model
            })
        end
        ESX.UI.Menu.CloseAll()
        ESX.UI.Menu.Open('default', GetCurrentResourceName(),
                         'funny_offert_menu', {
            title = "Lista Aut Używanych",
            align = "center",
            elements = elements
        }, function(data, menu) print(data.current.value) end,
                         function(data, menu) menu.close() end)
    end)
end

RegisterNetEvent('generalcity:open:offert')
AddEventHandler('generalcity:open:offert', function() OpenOffertMenu() end)

RegisterKeyMapping('cardealer', 'Menu Frakcji Cardealera', 'keyboard', 'F6')

RegisterNetEvent('generalcity:cardealer:client:sell')
AddEventHandler('generalcity:cardealer:client:sell', function(model, price, id)
    ESX.UI.Menu.CloseAll()
    ESX.UI.Menu.Open('default', GetCurrentResourceName(),
                     'funny_cardealer_client_sell', {
        title = "Czy Chcesz zakupić " .. model .. "?",
        align = "center",
        elements = {
            {label = "Tak", value = "yes"}, {label = "Nie", value = "no"}
        }
    }, function(data, menu)
        if data.current.value == 'yes' then
            TriggerServerEvent('generalcity:cardealer:server:sell',
                               data.current.value, model, price, id)
        else
            TriggerServerEvent('generalcity:cardealer:server:sell',
                               data.current.value, model, price, id)
        end
    end, function(data, menu) menu.close() end)
end)
