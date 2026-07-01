local utils = require "shared.utils"
local config = require "config"

---@type VehicleInfo
local currentVehicleInfo = nil

---@param vehicleInfo VehicleInfo
---@param mods table
---@param note string
local function sendToDiscord(vehicleInfo, mods, note)
    if not vehicleInfo then return end

    local player = exports.qbx_core:GetPlayerData()
    local playerName = player.charinfo.firstname .. " " .. player.charinfo.lastname
    local playerId = GetPlayerServerId(PlayerId())
    local modList = ""
    for _, modData in pairs(mods) do
        local currentStatus = modData.current <= 0 and "Stock" or tostring(modData.current)
        modList = modList .. ("%s Level: %s\n"):format(modData.name, currentStatus)
    end

    if modList == "" then
        modList = "No modifications"
    end

    local data = {
        playerName = playerName,
        playerId = playerId,
        vehicleInfo = vehicleInfo,
        mods = modList,
        note = note,
    }

    TriggerServerEvent("vehiclestatus:server:sendToDiscord", data)
end

local function showStatusMenu()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)

    if not vehicle or vehicle == 0 then
        exports.ox_lib:notify({
            title = "Not in Vehicle",
            description = "You must be in a vehicle to use this command",
            type = "error",
        })
        return
    end

    local vehicleInfo = utils.getVehicleInfo(vehicle)
    if not vehicleInfo then return end

    local mods = utils.getVehicleMods(vehicle)
    vehicleInfo.currentMods = mods

    if config.enableSpeedAnalytics then
        vehicleInfo.upgradedSpeed = utils.calculateUpgradedSpeed(vehicle, vehicleInfo.baselineSpeed)
    else
        vehicleInfo.upgradedSpeed = vehicleInfo.baselineSpeed
    end

    currentVehicleInfo = vehicleInfo

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "open",
        data = vehicleInfo
    })
end

RegisterNUICallback("close", function(_, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "close" })
    cb("ok")
end)

RegisterNUICallback("reportToDiscord", function(data, cb)
    local note = data and data.note or ""

    if not note or note == "" then
        exports.ox_lib:notify({
            title = "Note Required",
            description = "Please add a note before submitting",
            type = "error",
        })
        cb("ok")
        return
    end
    
    if currentVehicleInfo then

        sendToDiscord(currentVehicleInfo, currentVehicleInfo.currentMods, note)
        
        exports.ox_lib:notify({
            title = "Reports Sent",
            description = "Vehicle status has been sent to both public and staff channels",
            type = "success",
        })
    end
    cb("ok")
end)

RegisterNUICallback("reportToStaff", function(_, cb)
    cb("ok")
end)

RegisterCommand("status", function()
    showStatusMenu()
end, false)

RegisterKeyMapping("status", "Show Vehicle Status", "keyboard", "k")

CreateThread(function()
    while not exports.ox_lib do
        Wait(100)
    end
    exports.ox_lib:notify({
        title = "Vehicle Status",
        description = "Press K or use /status to view vehicle information",
        type = "inform",
    })
end)
