local QBCore = exports['qb-core']:GetCoreObject()

local carrying = false
local carriedPed = nil
local targetPed = nil
local addedTargetFor = nil

local function debugPrint(...)
    if Config.useDebug then
        print('[Slayer_npc_kidnap]', ...)
    end
end

local function LoadAnimDict(dict)
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Wait(10)
        end
    end
end

local function clearTarget()
    if addedTargetFor and DoesEntityExist(addedTargetFor) then
        exports.ox_target:removeLocalEntity(addedTargetFor)
    end
    addedTargetFor = nil
    targetPed = nil
end

local function isValidNpc(ped, playerPed)
    if not DoesEntityExist(ped) or not IsEntityAPed(ped) then return false end
    if IsPedAPlayer(ped) then return false end
    if IsPedDeadOrDying(ped) then return false end
    if not IsPedHuman(ped) then return false end
    if IsPedInAnyVehicle(ped, false) then return false end
    if #(GetEntityCoords(playerPed) - GetEntityCoords(ped)) > Config.aimDistance then return false end
    return true
end

local function threatenPed(ped, playerPed)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedFleeAttributes(ped, 0, false)
    SetPedSeeingRange(ped, 0.0)
    SetPedHearingRange(ped, 0.0)
    TaskHandsUp(ped, -1, playerPed, -1, true)
end

-- NUI open helper
local function openNuiForPed(ped)
    local netId = NetworkGetNetworkIdFromEntity(ped)
    SendNUIMessage({ action = 'open', netId = netId, carrying = carrying })
    SetNuiFocus(true, true)
end

RegisterNUICallback('close', function(_, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

local function stopCarrying()
    if not carrying or not carriedPed or not DoesEntityExist(carriedPed) then
        carrying = false
        carriedPed = nil
        return
    end
    DetachEntity(carriedPed, true, true)
    ClearPedTasks(carriedPed)
    ClearPedSecondaryTask(PlayerPedId())
    carrying = false
    local player = PlayerPedId()
    -- make ped flee
    TaskSmartFleePed(carriedPed, player, 50.0, -1, true, true)
    if Config.text.notifyStop ~= '' then
        lib.notify({title='Secuestro', description=Config.text.notifyStop, type='inform'})
    end
    carriedPed = nil
end

local function startCarrying(ped)
    if carrying then return end
    local player = PlayerPedId()
    carrying = true
    carriedPed = ped

    -- load anims
    local dict = 'anim@gangops@hostage@'
    LoadAnimDict(dict)
    -- play anims
    TaskPlayAnim(player, dict, 'perp_idle', 8.0, -8.0, -1, 49, 0.0, false, false, false)
    TaskPlayAnim(ped, dict, 'victim_idle', 8.0, -8.0, -1, 33, 0.0, false, false, false)

    -- attach ped to player
    AttachEntityToEntity(
        ped, player, Config.attach.bone,
        Config.attach.x, Config.attach.y, Config.attach.z,
        Config.attach.rx, Config.attach.ry, Config.attach.rz,
        false, false, false, true, 2, true
    )

    if Config.text.notifyStart ~= '' then
        lib.notify({title='Secuestro', description=Config.text.notifyStart, type='success'})
    end
end

RegisterNUICallback('kidnap', function(data, cb)
    local netId = data.netId
    local ped = NetworkGetEntityFromNetworkId(netId)
    if ped ~= 0 and isValidNpc(ped, PlayerPedId()) then
        startCarrying(ped)
    end
    cb('ok')
end)

RegisterNUICallback('release', function(_, cb)
    stopCarrying()
    cb('ok')
end)

RegisterNUICallback('putinveh', function(_, cb)
    if not carrying or not carriedPed then cb('ok') return end
    local player = PlayerPedId()
    local pos = GetEntityCoords(player)
    local veh = GetClosestVehicle(pos.x, pos.y, pos.z, 5.0, 0, 70)
    if veh == 0 then
        lib.notify({title='Secuestro', description=Config.text.noVehicle, type='error'})
        cb('ok')
        return
    end
    DetachEntity(carriedPed, true, true)
    ClearPedTasks(carriedPed)
    for seat = 0, GetVehicleMaxNumberOfPassengers(veh) do
        if IsVehicleSeatFree(veh, seat) then
            TaskWarpPedIntoVehicle(carriedPed, veh, seat)
            break
        end
    end
    carrying = false
    carriedPed = nil
    cb('ok')
end)

RegisterNUICallback('takeoutveh', function(_, cb)
    -- find ped in nearest vehicle seat, try to unseat if we were carrying them
    if carriedPed and IsPedInAnyVehicle(carriedPed, false) then
        local veh = GetVehiclePedIsIn(carriedPed, false)
        TaskLeaveVehicle(carriedPed, veh, 64)
        Wait(1000)
        threatenPed(carriedPed, PlayerPedId())
    end
    cb('ok')
end)

-- Cancel if player dies or enters a vehicle
CreateThread(function()
    while true do
        if carrying then
            local player = PlayerPedId()
            if IsPedDeadOrDying(player) or IsPedInAnyVehicle(player, false) then
                stopCarrying()
            end
            if Config.disableControlsWhileCarrying then
                DisableControlAction(0, 24, true) -- attack
                DisableControlAction(0, 25, true) -- aim
                DisableControlAction(0, 21, true) -- sprint
                DisableControlAction(0, 22, true) -- jump
                DisableControlAction(0, 44, true) -- cover
            end
        end
        Wait(0)
    end
end)

-- Aiming detection and dynamic ox_target registration
CreateThread(function()
    while true do
        Wait(150)
        if carrying then
            -- do not allow selecting other targets while carrying
            clearTarget()
        else
            local playerId = PlayerId()
            local playerPed = PlayerPedId()
            if Config.minWeaponThreat and not IsPedArmed(playerPed, 4) then
                clearTarget()
            else
                if IsPlayerFreeAiming(playerId) then
                    local success, entity = GetEntityPlayerIsFreeAimingAt(playerId)
                    if success and entity ~= 0 and isValidNpc(entity, playerPed) then
                        if targetPed ~= entity then
                            clearTarget()
                            targetPed = entity
                            threatenPed(targetPed, playerPed)
                            exports.ox_target:addLocalEntity(targetPed, {
                                {
                                    name = 'snk_open_menu',
                                    label = Config.text.targetLabel,
                                    icon = 'fa-solid fa-user-lock',
                                    onSelect = function(data)
                                        openNuiForPed(targetPed)
                                    end
                                }
                            })
                            addedTargetFor = targetPed
                            debugPrint('Added ox_target to ped', targetPed)
                        end
                    else
                        clearTarget()
                    end
                else
                    clearTarget()
                end
            end
        end
    end
end)
