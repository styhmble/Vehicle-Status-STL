---@class VehicleInfo
---@field spawncode string The vehicle model name
---@field modelHash number The vehicle model hash
---@field displayName string The localized display name
---@field class number Vehicle class ID
---@field className string Vehicle class name
---@field baselineSpeed number Baseline max speed (mph)
---@field upgradedSpeed number Fully upgraded max speed (mph)
---@field currentMods table<number, {name: string, levels: number, current: number}>
---@field plate string Vehicle plate
---@field acceleration number
---@field gears number
---@field capacity number
---@param classId number
---@return string
local function getVehicleClassName(classId)
    local classNames = {
        [0] = "Compacts",
        [1] = "Sedans",
        [2] = "SUVs",
        [3] = "Coupes",
        [4] = "Muscle",
        [5] = "Sports Classics",
        [6] = "Sports",
        [7] = "Super",
        [8] = "Motorcycles",
        [9] = "Off-road",
        [10] = "Industrial",
        [11] = "Utility",
        [12] = "Vans",
        [13] = "Cycles",
        [14] = "Boats",
        [15] = "Helicopters",
        [16] = "Planes",
        [17] = "Service",
        [18] = "Emergency",
        [19] = "Military",
        [20] = "Commercial",
        [21] = "Trains",
    }
    return classNames[classId] or "Unknown"
end

--- @param speed number Speed in m/s
--- @return number
local function toMph(speed)

    local realismFactor = 1.165
    return math.ceil(speed * 2.23694 * realismFactor)
end

---@param vehicle number Vehicle handle
---@return VehicleInfo?
local function getVehicleInfo(vehicle)
    if not DoesEntityExist(vehicle) then return nil end
    
    local model = GetEntityModel(vehicle)
    local spawncode = GetDisplayNameFromVehicleModel(model):lower()
    local displayName = GetLabelText(GetDisplayNameFromVehicleModel(model))
    
    if displayName == "NULL" then
        displayName = spawncode
    end
    
    local classId = GetVehicleClass(vehicle)
    local className = getVehicleClassName(classId)
    local baselineSpeedNative = GetVehicleModelMaxSpeed(model)
    local baselineSpeed = toMph(baselineSpeedNative)
    local plate = GetVehicleNumberPlateText(vehicle)
    local acceleration = GetVehicleAcceleration(vehicle)
    local gears = GetVehicleHighGear(vehicle)
    local capacity = GetVehicleMaxNumberOfPassengers(vehicle) + 1
    
    return {
        spawncode = spawncode,
        modelHash = model,
        displayName = displayName,
        class = classId,
        className = className,
        baselineSpeed = baselineSpeed,
        plate = plate,
        acceleration = math.floor(acceleration * 100) / 100,
        gears = gears,
        capacity = capacity,
    }
end
e
---@param vehicle number Vehicle handle
---@return table<number, {name: string, levels: number, current: number}>
local function getVehicleMods(vehicle)
    local mods = {}
    local config = require "config"

    local modTypes = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 22, 23}
    
    for _, modType in ipairs(modTypes) do
        local numMods = GetNumVehicleMods(vehicle, modType)
        if numMods > 0 then
            local currentMod = GetVehicleMod(vehicle, modType)
            local modName = config.modTypeNames[modType] or ("Mod " .. modType)
            
            mods[modType] = {
                name = modName,
                levels = numMods,
                current = currentMod + 1, -- Convert to 1-based index (0 = stock)
            }

            if currentMod == -1 then
                mods[modType].current = 0
            end
        end
    end
    
    return mods
end

--- Calculate upgraded speed based on engine/transmission upgrades
--- @param vehicle number Vehicle handle
--- @param baselineSpeed number Baseline speed (in mph)
--- @return number
local function calculateUpgradedSpeed(vehicle, baselineSpeed)
    local config = require "config"
    local classId = GetVehicleClass(vehicle)
    local classMultiplier = config.classSpeedMultipliers[classId] or 1.20
    local upgradedSpeed = math.ceil(baselineSpeed * classMultiplier)
    
    return upgradedSpeed
end

--- @param modelHash number The vehicle model hash
--- @return string
local function modelHashToHex(modelHash)
    return string.format("%x", modelHash):upper()
end

---@param vehicle number Vehicle handle
---@return table
local function getVehicleHandlingInfo(vehicle)
    if not DoesEntityExist(vehicle) then return {} end

    local model = GetEntityModel(vehicle)
    local acceleration = GetVehicleAcceleration(vehicle)
    local maxSpeed = GetVehicleModelMaxSpeed(model)
    local fInitialDriveForce = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDriveForce")
    local fDriveInertia = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fDriveInertia")
    local fInitialDriveMaxFlatVel = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDriveMaxFlatVel")
    local fBrakeForce = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fBrakeForce")
    local fBrakeBiasFront = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fBrakeBiasFront")
    local fHandBrakeForce = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fHandBrakeForce")
    local fSteeringLock = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fSteeringLock")
    local fTractionCurveMax = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fTractionCurveMax")
    local fTractionCurveMin = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fTractionCurveMin")
    local fLowSpeedTractionLossMult = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fLowSpeedTractionLossMult")
    local fTractionLossMult = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fTractionLossMult")
    local fCollisionDamageMult = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fCollisionDamageMult")
    local fWeaponDamageMult = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fWeaponDamageMult")
    local fDeformationDamageMult = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fDeformationDamageMult")
    local fEngineDamageMult = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fEngineDamageMult")
    local fRollCentreHeightFront = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fRollCentreHeightFront")
    local fRollCentreHeightRear = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fRollCentreHeightRear")
    local hasBoost = GetVehicleMod(vehicle, 40) == 1
    local handlingFlags = GetVehicleHandlingInt(vehicle, "CHandlingData", "nModelFlags")
    if handlingFlags then
        local hasNitrousFlag = (handlingFlags & 0x20) ~= 0
        local hasRocketFlag = (handlingFlags & 0x40) ~= 0
        hasBoost = hasBoost or hasNitrousFlag or hasRocketFlag
    end

    return {
        acceleration = math.floor(acceleration * 100) / 100,
        maxSpeed = math.floor(maxSpeed * 100) / 100,
        fInitialDriveForce = fInitialDriveForce,
        fDriveInertia = fDriveInertia,
        fInitialDriveMaxFlatVel = fInitialDriveMaxFlatVel,
        fBrakeForce = fBrakeForce,
        fBrakeBiasFront = fBrakeBiasFront,
        fHandBrakeForce = fHandBrakeForce,
        fSteeringLock = fSteeringLock,
        fTractionCurveMax = fTractionCurveMax,
        fTractionCurveMin = fTractionCurveMin,
        fLowSpeedTractionLossMult = fLowSpeedTractionLossMult,
        fTractionLossMult = fTractionLossMult,
        fCollisionDamageMult = fCollisionDamageMult,
        fWeaponDamageMult = fWeaponDamageMult,
        fDeformationDamageMult = fDeformationDamageMult,
        fEngineDamageMult = fEngineDamageMult,
        fRollCentreHeightFront = fRollCentreHeightFront,
        fRollCentreHeightRear = fRollCentreHeightRear,
        hasBoost = hasBoost,
    }
end

return {
    getVehicleInfo = getVehicleInfo,
    getVehicleMods = getVehicleMods,
    calculateUpgradedSpeed = calculateUpgradedSpeed,
    modelHashToHex = modelHashToHex,
    getVehicleHandlingInfo = getVehicleHandlingInfo,
}