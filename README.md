
# SFRP-Hideintrash
SFRP-Hideintrash is a very unique script that I may work on more if it gets positive reviews. It is only a qb-target and qb-core compatible script so far but I play to make it compatible for ox_core and ESX in the near future

- Edits are not allowed without giving credit to me
- SFRP-Hideintrash Works By Using QB-Target Or OX_Target On A Dumpster And Pressing [E] To Get Out

# How To Set Up
- Download the zip file
- Unzip the .zip file
- Put It In Your Resources
- Change The Config To Suit You


Heres a preview of the config
```
Config = {}

Config.Dumpster = {
    `prop_dumpster_01a`,
    `prop_dumpster_02a`,
    `prop_dumpster_02b`,
    `prop_dumpster_4a`,
    `prop_dumpster_4b`,
}

Config.Target = 'qb' -- qb or ox

Config.Notify = 'qb'  -- qb or ox


------------------------------------------------------------- ONLY TOUCH IF YOU KNOW WHAT YOURE DOING

--   https://forge.plebmasters.de/animations/anim@amb@nightclub@lazlow@lo_alone@@lowalone_base_laz?ped=A_F_Y_Beach_01
Config.Scenario = 'anim@amb@nightclub@lazlow@lo_alone@'
Config.ScenarioType = 'lowalone_base_laz'


-----------------------------------     What Im Working On 

--[[

Better way to get out of the dumpster

Maybe Sound Effects When Your In The Dumpster

Let me know by starring the github if I should focus more on this script

]]


```
client.lua
```
local QBCore = exports['qb-core']:GetCoreObject()
local isInTrash = false
local dumpsters = Config.Dumpster
local originalCoords = nil 

CreateThread(function()
    while GetResourceState("ox_target") ~= "started" do
        Wait(500)
    end

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
        exports['ox_target']:addModel(dumpsters, {
            options = {
                {
                    name = "hide",
                    label = "Hide In Dumpster",
                    icon = "fa-solid fa-trash",
                    event = "sfrp-hideintrash:client:enterTrash",
                    distance = 2.0,
                }
            }
        })
    end
end)

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


```

# Features
- A cool script for your server
- A very simple script to plug into your RP situations
- Uses Very Limited Server ms 0.00 - 0.05
- QB-Target
- OX_Target
- QB-Core Notify
- Ox_Lib Notify
- Customizable Everything

# Upcoming Features
- ox_core
- ESX

