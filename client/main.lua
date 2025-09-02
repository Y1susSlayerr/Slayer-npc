local QBCore = exports['qb-core']:GetCoreObject()

local carrying = false
local carriedPed = nil
local targetPed = nil

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

local function openNuiForPed(ped)
    local netId = NetworkGetNetworkIdFromEntity(ped)
    SendNUIMessage({ action = 'open', netId = netId, carrying = carrying })
    SetNuiFocus(true, false)
end

local function closeNui()
    SendNUIMessage({ action = 'hide' })
    SetNuiFocus(false, false)
end

RegisterNUICallback('close', function(_, cb)
    closeNui()
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

    local dict = 'anim@gangops@hostage@'
    LoadAnimDict(dict)
    TaskPlayAnim(player, dict, 'perp_idle', 8.0, -8.0, -1, 49, 0.0, false, false, false)
    TaskPlayAnim(ped, dict, 'victim_idle', 8.0, -8.0, -1, 33, 0.0, false, false, false)

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

RegisterNUICallback('kneel', function(data, cb)
    local netId = data.netId
    local ped = NetworkGetEntityFromNetworkId(netId)
    if ped ~= 0 and isValidNpc(ped, PlayerPedId()) then
        LoadAnimDict('random@arrests@busted')
        TaskPlayAnim(ped, 'random@arrests@busted', 'idle_a', 8.0, -8.0, -1, 1, 0.0, false, false, false)
    end
    cb('ok')
end)

RegisterNUICallback('release', function(_, cb)
    if carrying then
        stopCarrying()
    elseif targetPed and DoesEntityExist(targetPed) then
        ClearPedTasks(targetPed)
        TaskSmartFleePed(targetPed, PlayerPedId(), 50.0, -1, true, true)
    end
    cb('ok')
end)

CreateThread(function()
    while true do
        if carrying then
            local player = PlayerPedId()
            if IsPedDeadOrDying(player) or IsPedInAnyVehicle(player, false) then
                stopCarrying()
            end
            if Config.disableControlsWhileCarrying then
                DisableControlAction(0, 24, true)
                DisableControlAction(0, 25, true)
                DisableControlAction(0, 21, true)
                DisableControlAction(0, 22, true)
                DisableControlAction(0, 44, true)
            end
            if IsControlJustPressed(0, 73) then -- X key
                stopCarrying()
            end
        end
        Wait(0)
    end
end)

CreateThread(function()
    while true do
        Wait(150)
        if carrying then
            if targetPed then
                targetPed = nil
                closeNui()
            end
        else
            local playerId = PlayerId()
            local playerPed = PlayerPedId()
            if Config.minWeaponThreat and not IsPedArmed(playerPed, 4) then
                if targetPed then
                    targetPed = nil
                    closeNui()
                end
            else
                if IsPlayerFreeAiming(playerId) then
                    local success, entity = GetEntityPlayerIsFreeAimingAt(playerId)
                    if success and entity ~= 0 and isValidNpc(entity, playerPed) then
                        if targetPed ~= entity then
                            targetPed = entity
                            threatenPed(targetPed, playerPed)
                            openNuiForPed(targetPed)
                        end
                    else
                        if targetPed then
                            targetPed = nil
                            closeNui()
                        end
                    end
                else
                    if targetPed then
                        targetPed = nil
                        closeNui()
                    end
                end
            end
        end
    end
end)
