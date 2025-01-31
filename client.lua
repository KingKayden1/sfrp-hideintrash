local QBCore = exports['qb-core']:GetCoreObject()
local isInTrash = false
local dumpsters = Config.Dumpster
local originalCoords = nil 
local ox_target = exports.ox_target

if Config.Target == 'qb' then
    exports['qb-target']:AddTargetModel(dumpsters, {
        options = {
            {
                type = "client",
                event = "sfrp-hideintrash:client:enterTrash",
                icon = "fas fa-trash",
                label = "Hide in Trash",
            },
        },
        distance = 2.5,
    })
elseif Config.Target == 'ox' then
    ox_target:addModel(dumpsters, {
        {
            name = 'dumpster',
            event = 'sfrp-hideintrash:client:enterTrash',
            icon = 'fas fa-trash',
            label = "Hide in Trash",
        }
    })
end

RegisterNetEvent('sfrp-hideintrash:client:enterTrash', function()
    if isInTrash then
        if Config.Notify == 'qb' then
            QBCore.Functions.Notify('You are already hiding in the trash.', 'error', 2500)
        elseif Config.Notify == 'ox' then
            exports.ox_lib:notify({
                title = 'Dumpster',
                description = 'You are already hiding in the trash.',
                type = 'error'
            })
        end
        return
    end

    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    local closestDumpster = nil
    for _, model in pairs(dumpsters) do
        local dumpster = GetClosestObjectOfType(playerCoords.x, playerCoords.y, playerCoords.z, 2.5, model, false, false, false)
        if dumpster and DoesEntityExist(dumpster) then
            closestDumpster = dumpster
            break
        end
    end

    if closestDumpster then
        local dumpsterCoords = GetEntityCoords(closestDumpster)
        local minDim, _ = GetModelDimensions(GetEntityModel(closestDumpster)) 
        local centerCoords = vector3(
            dumpsterCoords.x,
            dumpsterCoords.y,
            dumpsterCoords.z + minDim.z + 0.5 
        )

        originalCoords = playerCoords

        SetEntityCoords(playerPed, centerCoords.x, centerCoords.y, centerCoords.z, false, false, false, true)
        FreezeEntityPosition(playerPed, true)
        isInTrash = true

        LoadAnimDict(Config.Scenario)
        TaskPlayAnim(playerPed, Config.Scenario, Config.ScenarioType, 8.0, -8.0, -1, 1, 0, false, false, false)


        if Config.Notify == 'qb' then
            QBCore.Functions.Notify('You are hiding in the trash.', 'success')
        elseif Config.Notify == 'ox' then
            exports.ox_lib:notify({
                title = 'Dumpster',
                description = 'You are now hiding in the trash.',
                type = 'success'
            })
        end
    else
        if Config.Notify == 'qb' then
            QBCore.Functions.Notify('No nearby dumpster found!', 'error')
        elseif Config.Notify == 'ox' then
            exports.ox_lib:notify({
                title = 'Dumpster',
                description = 'No Nearby Dumpster Found',
                type = 'error'
            })
        end
    end
end)

RegisterNetEvent('sfrp-hideintrash:client:exitTrash', function()
    if not isInTrash then
        if Config.Notify == 'qb' then
            QBCore.Functions.Notify('You are not hiding in the trash.', 'error')
        elseif Config.Notify == 'ox' then
            exports.ox_lib:notify({
                title = 'Dumpster',
                description = 'You are not hiding in the trash.',
                type = 'error'
            })
        end
        return
    end

    local playerPed = PlayerPedId()
    SetEntityCoords(playerPed, originalCoords.x, originalCoords.y, originalCoords.z, false, false, false, true)
    FreezeEntityPosition(playerPed, false)
    ClearPedTasksImmediately(playerPed)
    isInTrash = false

    if Config.Notify == 'qb' then
        QBCore.Functions.Notify('You got out of the trash.', 'success')
    elseif Config.Notify == 'ox' then
        exports.ox_lib:notify({
            title = 'Dumpster',
            description = 'You exited the dumpster.',
            type = 'success'
        })
    end
end)

CreateThread(function()
    while true do
        Wait(0)
        if isInTrash and IsControlJustReleased(0, 38) then
            TriggerEvent('sfrp-hideintrash:client:exitTrash')
        end
    end
end)

function LoadAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Wait(10)
    end
end
