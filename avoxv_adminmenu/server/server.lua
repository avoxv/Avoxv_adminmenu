local ESX = exports['es_extended']:getSharedObject()

ESX.RegisterServerCallback('avoxv_adminmenu:getGroup', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)

    if Config.AdminGroups[xPlayer.getGroup()] then
        cb(true)
    else
        cb(false)
    end
end)

RegisterNetEvent('avoxv_adminmenu:revive')
AddEventHandler('avoxv_adminmenu:revive', function(id)
    TriggerClientEvent('avoxv_adminmenu:revivePlayer', id)
end)

RegisterNetEvent('avoxv_adminmenu:heal')
AddEventHandler('avoxv_adminmenu:heal', function(id)
    TriggerClientEvent('avoxv_adminmenu:healPlayer', id)
end)

RegisterNetEvent('avoxv_adminmenu:giveItem')
AddEventHandler('avoxv_adminmenu:giveItem', function(id, item, count)
    local xPlayer = ESX.GetPlayerFromId(id)

    if xPlayer then
        xPlayer.addInventoryItem(item, count)
    end
end)

RegisterNetEvent('avoxv_adminmenu:setJob')
AddEventHandler('avoxv_adminmenu:setJob', function(id, job, grade)
    local xPlayer = ESX.GetPlayerFromId(id)

    if xPlayer then
        xPlayer.setJob(job, grade)
    end
end)