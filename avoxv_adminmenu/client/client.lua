local ESX = exports['es_extended']:getSharedObject()

local noclip = false
local staffmode = false

RegisterCommand(Config.MenuCommand, function()
    ESX.TriggerServerCallback('avoxv_adminmenu:getGroup', function(hasPerms)
        if not hasPerms then
            lib.notify({
                title = 'Admin Menu',
                description = 'No permission.',
                type = 'error'
            })
            return
        end

        OpenAdminMenu()
    end)
end)

function OpenAdminMenu()
    lib.registerContext({
        id = 'admin_main',
        title = 'Avoxv Admin Menu',
        options = {
            {
                title = 'Player Options',
                icon = 'users',
                menu = 'player_options'
            },
            {
                title = 'Teleport Options',
                icon = 'location-dot',
                menu = 'teleport_options'
            },
            {
                title = 'Vehicle Options',
                icon = 'car',
                menu = 'vehicle_options'
            },
            {
                title = 'Staff Options',
                icon = 'shield',
                menu = 'staff_options'
            }
        }
    })

    lib.registerContext({
        id = 'staff_options',
        title = 'Staff Options',
        menu = 'admin_main',
        options = {
            {
                title = 'Toggle Noclip',
                onSelect = function()
                    ToggleNoclip()
                end
            },
            {
                title = 'Toggle Staff Mode',
                onSelect = function()
                    staffmode = not staffmode

                    lib.notify({
                        title = 'Staff Mode',
                        description = staffmode and 'Enabled' or 'Disabled',
                        type = 'success'
                    })
                end
            }
        }
    })

    lib.registerContext({
        id = 'vehicle_options',
        title = 'Vehicle Options',
        menu = 'admin_main',
        options = {
            {
                title = 'Spawn Vehicle',
                onSelect = function()
                    local input = lib.inputDialog('Spawn Vehicle', {
                        {'Vehicle Spawn Name', type = 'input'}
                    })

                    if input then
                        local model = input[1]

                        RequestModel(model)
                        while not HasModelLoaded(model) do Wait(0) end

                        local ped = PlayerPedId()
                        local coords = GetEntityCoords(ped)

                        local veh = CreateVehicle(model, coords.x, coords.y, coords.z, GetEntityHeading(ped), true, false)

                        TaskWarpPedIntoVehicle(ped, veh, -1)
                    end
                end
            },
            {
                title = 'Delete Vehicle',
                onSelect = function()
                    local veh = GetVehiclePedIsIn(PlayerPedId(), false)

                    if veh ~= 0 then
                        DeleteEntity(veh)
                    end
                end
            }
        }
    })

    lib.registerContext({
        id = 'teleport_options',
        title = 'Teleport Options',
        menu = 'admin_main',
        options = {
            {
                title = 'Teleport To Waypoint',
                onSelect = function()
                    local blip = GetFirstBlipInfoId(8)

                    if DoesBlipExist(blip) then
                        local coords = GetBlipInfoIdCoord(blip)
                        SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z)
                    end
                end
            }
        }
    })

    lib.registerContext({
        id = 'player_options',
        title = 'Player Options',
        menu = 'admin_main',
        options = {
            {
                title = 'Revive Player',
                onSelect = function()
                    local input = lib.inputDialog('Revive Player', {
                        {'Player ID', type = 'number'}
                    })

                    if input then
                        TriggerServerEvent('avoxv_adminmenu:revive', input[1])
                    end
                end
            },
            {
                title = 'Heal Player',
                onSelect = function()
                    local input = lib.inputDialog('Heal Player', {
                        {'Player ID', type = 'number'}
                    })

                    if input then
                        TriggerServerEvent('avoxv_adminmenu:heal', input[1])
                    end
                end
            },
            {
                title = 'Give Item',
                onSelect = function()
                    local input = lib.inputDialog('Give Item', {
                        {'Player ID', type = 'number'},
                        {'Item Name', type = 'input'},
                        {'Amount', type = 'number'}
                    })

                    if input then
                        TriggerServerEvent('avoxv_adminmenu:giveItem', input[1], input[2], input[3])
                    end
                end
            },
            {
                title = 'Set Job',
                onSelect = function()
                    local input = lib.inputDialog('Set Job', {
                        {'Player ID', type = 'number'},
                        {'Job Name', type = 'input'},
                        {'Grade', type = 'number'}
                    })

                    if input then
                        TriggerServerEvent('avoxv_adminmenu:setJob', input[1], input[2], input[3])
                    end
                end
            }
        }
    })

    lib.showContext('admin_main')
end

function ToggleNoclip()
    noclip = not noclip

    local ped = PlayerPedId()

    SetEntityInvincible(ped, noclip)
    SetEntityVisible(ped, not noclip, false)

    CreateThread(function()
        while noclip do
            Wait(0)

            local coords = GetEntityCoords(ped)
            local forward = GetEntityForwardVector(ped)

            if IsControlPressed(0, 32) then
                coords = coords + forward * 1.5
            end

            if IsControlPressed(0, 269) then
                coords = coords - forward * 1.5
            end

            SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, true, true, true)
        end
    end)
end

RegisterNetEvent('avoxv_adminmenu:healPlayer')
AddEventHandler('avoxv_adminmenu:healPlayer', function()
    SetEntityHealth(PlayerPedId(), 200)
end)

RegisterNetEvent('avoxv_adminmenu:revivePlayer')
AddEventHandler('avoxv_adminmenu:revivePlayer', function()
    TriggerEvent('esx_ambulancejob:revive')
end)