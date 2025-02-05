QBCore = exports['qb-core']:GetCoreObject()

local isInTrash = false
local dumpsters = Config.Dumpster
local originalCoords = nil 
local ox_target = exports.ox_target
local suffocationTimer = nil

local function drawNativeNotification(text)
    SetTextComponentFormat("STRING")
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

if Config.Enabled == true then
    if Config.Framework.target == 'qb' then
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
    elseif Config.Framework.target == 'ox' then
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
            if Config.Framework.notify == 'qb' then
                QBCore.Functions.Notify('You are already hiding in the trash.', 'error', 2500)
            elseif Config.Framework.notify == 'ox' then
                exports.ox_lib:notify({
                    title = 'Dumpster',
                    description = 'You are already hiding in the trash.',
                    type = 'error'
                })
            elseif Config.Framework.notify == 'standalone' then
                drawNativeNotification('You are alrady hiding in the trash')
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

            if Config.Enter.invisibility  == true then
                SetEntityVisible(playerPed, false, false)
            elseif Config.Enter.invisibility == false then
                LoadAnimDict(Config.Enter.animation.scenario)
                TaskPlayAnim(playerPed, Config.Enter.animation.scenario, Config.Enter.animation.scenarioType, 8.0, -8.0, -1, 1, 0, false, false, false)
            end



            if Config.DrawText.native == true then
                CreateThread(function()
                    while isInTrash do
                        Wait(0)
                        local playerCoords = GetEntityCoords(PlayerPedId())
                        DrawText3Ds(playerCoords.x, playerCoords.y, playerCoords.z, Config.DrawText.text)
                    end
                end)
            elseif Config.DrawText.native == false then
                exports['qb-core']:DrawText(Config.DrawText.text, Config.DrawText.qbcore.position) -- "left", "right", "top", etc.
            elseif Config.DrawText.native== 'standalone' then
                drawNativeNotification(Config.DrawText.text)
            end



            if Config.Framework.notify == 'qb' then
                QBCore.Functions.Notify('You are hiding in the trash.', 'success')
            elseif Config.Framework.notify == 'ox' then
                exports.ox_lib:notify({
                    title = 'Dumpster',
                    description = 'You are now hiding in the trash.',
                    type = 'success'
                })
            elseif Config.Framework.notify == 'standalone' then
                drawNativeNotification('You are now hiding in the trash')
            end
        else
            if Config.Framework.notify == 'qb' then
                QBCore.Functions.Notify('No nearby dumpster found!', 'error')
            elseif Config.Framework.notify == 'ox' then
                exports.ox_lib:notify({
                    title = 'Dumpster',
                    description = 'No Nearby Dumpster Found',
                    type = 'error'
                })
            elseif Config.Framework.notify == 'standalone' then
                drawNativeNotification('No Nearby Dumpster Found')
            end
        end
        if Config.Suffocation.enabled then
            StartSuffocationTimer()
        else
            if Config.Framework.notify == 'qb' then
                QBCore.Functions.Notify('Your Suffocating!', 'error')
            elseif Config.Framework.notify == 'ox' then
                exports.ox_lib:notify({
                    title = 'Dumpster',
                    description = 'Your Suffocating',
                    type = 'error'
                })
            elseif Config.Framework.notify == 'standalone' then
                drawNativeNotification('Your Suffocating')
            end
        end
    end)

    RegisterNetEvent('sfrp-hideintrash:client:exitTrash', function()
        if not isInTrash then
            if Config.Framework.notify == 'qb' then
                QBCore.Functions.Notify('You are not hiding in the trash.', 'error')
            elseif Config.Framework.notify == 'ox' then
                exports.ox_lib:notify({
                    title = 'Dumpster',
                    description = 'You are not hiding in the trash.',
                    type = 'error'
                })
            elseif Config.Framework.notify == 'standalone' then
                drawNativeNotification('You are not hiding in the trash')
            end
            return
        end

        local playerPed = PlayerPedId()
        SetEntityCoords(playerPed, originalCoords.x, originalCoords.y, originalCoords.z, false, false, false, true)
        FreezeEntityPosition(playerPed, false)
        ClearPedTasksImmediately(playerPed)
        isInTrash = false
        if Config.DrawText.native == false then
            exports['qb-core']:HideText()
        end

        if Config.Enter.invisibility == true then
            SetEntityVisible(playerPed, true, false)
        end

        if Config.Framework.notify == 'qb' then
            QBCore.Functions.Notify('You got out of the trash.', 'success')
        elseif Config.Framework.notify == 'ox' then
            exports.ox_lib:notify({
                title = 'Dumpster',
                description = 'You exited the dumpster.',
                type = 'success'
            })
        elseif Config.Framework.notify == 'standalone' then
            drawNativeNotification("You exited the dumpster")
        end
        StopSuffocation()
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

    function DrawText3Ds(x, y, z, text)
        local onScreen, _x, _y = World3dToScreen2d(x, y, z)

        if onScreen then
            local factor = #text / 460  -- Text width scaling based on length

            SetTextScale(0.35, 0.35)  -- Fixed size
            SetTextFont(4)
            SetTextProportional(1)
            SetTextColour(1, 85, 140, 255)
            SetTextCentre(1)

            SetTextEntry("STRING")
            AddTextComponentString(text)
            DrawText(_x, _y)

            -- Background rectangle for better readability
            DrawRect(_x, _y + 0.015, 0.02 + factor, 0.03, 0, 0, 0, 150)
        end
    end

    function StartSuffocationTimer()
        Citizen.CreateThread(function()
            Citizen.Wait(Config.Suffocation.timeBeforeSuffocation * 1000)

            while isInTrash do
                local playerPed = PlayerPedId()
                local health = GetEntityHealth(playerPed)

                if health > 101 then 
                    SetEntityHealth(playerPed, health - Config.Suffocation.damagePerTick)
                    if Config.Framework.notify == 'qb' then
                        QBCore.Functions.Notify("You're suffocating! Leave the dumpster!", "error")
                    elseif Config.Framework.notify == 'ox' then
                        exports.ox_lib:notify({
                            title = 'Dumpster',
                            description = 'Your Suffocating, Get Out!',
                            type = 'error'
                        })
                    elseif Config.Framework.notify == 'standalone' then
                        drawNativeNotification('Your Suffocating! Get OUT')
                    end
                else
                    -- 💀 Force Exit & Kill the Player 💀
                    TriggerEvent('sfrp-hideintrash:client:exitTrash')
                    Citizen.Wait(500)
                    SetEntityHealth(playerPed, 0)
                    SetPedToRagdoll(playerPed, 5000, 5000, 0, true, true, false)


                    if Config.Framework.notify == 'qb' then
                        QBCore.Functions.Notify("You suffocated in the dumpster.", "error")
                    elseif Config.Framework.notify == 'ox' then
                        exports.ox_lib:notify({
                            title = 'Dumpster',
                            description = 'You Suffocated',
                            type = 'error'
                        })
                    elseif Config.Framework.notify == 'standalone' then
                        drawNativeNotification('You Suffocated')
                    end
                    return
                end

                Citizen.Wait(Config.Suffocation.tickRate * 1000)
            end
        end)
    end


    function StopSuffocation()
        suffocationTimer = nil
    end
elseif Config.Enabled == false then
    print(Config.Print)
end
