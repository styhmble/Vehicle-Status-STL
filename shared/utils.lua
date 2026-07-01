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

---@param vehicle number Vehicle handle
---@return table<number, {name: string, levels: number, current: number}>
local function getVehicleMods(vehicle)
    local mods = {}
    local config = require "config"
    
    -- Common mod types to check
    local modTypes = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 22, 23}
    
    for _, modType in ipairs(modTypes) do
        local numMods = GetNumVehicleMods(vehicle, modType)
        if numMods > 0 then
            local currentMod = GetVehicleMod(vehicle, modType)
            local modName = config.modTypeNames[modType] or ("Mod " .. modType)
            
            mods[modType] = {
                name = modName,
                levels = numMods,
                current = currentMod + 1, 
            }

            if currentMod == -1 then
                mods[modType].current = 0
            end
        end
    end
    
    return mods
end

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

return {
    getVehicleInfo = getVehicleInfo,
    getVehicleMods = getVehicleMods,
    calculateUpgradedSpeed = calculateUpgradedSpeed,
}