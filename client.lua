local QBCore = exports['qb-core']:GetCoreObject()
local isInTrash = false
local dumpsters = Config.Dumpster
local originalCoords = nil 

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

RegisterNetEvent('sfrp-hideintrash:client:enterTrash', function()
    if isInTrash then
        TriggerEvent('QBCore:Notify', 'You are already hiding in the trash.', 'error')
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
        local minDim, maxDim = GetModelDimensions(GetEntityModel(closestDumpster))
        local centerCoords = vector3(
            dumpsterCoords.x,
            dumpsterCoords.y,
            dumpsterCoords.z + minDim.z + 0.5
        )

        originalCoords = playerCoords

        SetEntityCoords(playerPed, centerCoords.x, centerCoords.y, centerCoords.z, false, false, false, true)
        FreezeEntityPosition(playerPed, true)
        isInTrash = true

        LoadAnimDict("amb@world_human_bum_slumped@male@laying_on_right_side@base")
        TaskPlayAnim(playerPed, "amb@world_human_bum_slumped@male@laying_on_right_side@base", "base", 8.0, -8.0, -1, 1, 0, false, false, false)

        TriggerEvent('QBCore:Notify', 'You are hiding in the trash.', 'success')
    else
        TriggerEvent('QBCore:Notify', 'No nearby dumpster found!', 'error')
    end
end)

RegisterNetEvent('sfrp-hideintrash:client:exitTrash', function()
    if not isInTrash then
        TriggerEvent('QBCore:Notify', 'You are not hiding in the trash.', 'error')
        return
    end

    local playerPed = PlayerPedId()

    SetEntityCoords(playerPed, originalCoords.x, originalCoords.y, originalCoords.z, false, false, false, true)
    FreezeEntityPosition(playerPed, false) 
    ClearPedTasksImmediately(playerPed) 
    isInTrash = false

    TriggerEvent('QBCore:Notify', 'You got out of the trash.', 'success')
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
