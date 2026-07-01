local svConfig = require "sv_config"
local config = require "config"

---@param webhook string
---@param embed table
local function sendDiscordEmbed(webhook, embed)
    local payload = json.encode({
        username = "Vehicle Status Bot",
        avatar_url = "https://i.imgur.com/AfFp7pu.png",
        embeds = {embed},
    })
    
    PerformHttpRequest(webhook, function(err, text, headers)
        if err < 200 or err >= 300 then
            print(("[vehiclestatus] Discord webhook error: %d - %s"):format(err, text or ""))
        end
    end, "POST", payload, {
        ["Content-Type"] = "application/json",
    })
end

RegisterNetEvent("vehiclestatus:server:sendToDiscord", function(data)
    local src = source

    local player = exports.qbx_core:GetPlayer(src)
    if not player then return end
    local license = GetPlayerIdentifierByType(src, "license")
    local discord = GetPlayerIdentifierByType(src, "discord")
    local vehicleInfo = data.vehicleInfo
    local mods = data.mods
    local note = data.note or ""

    if not note or note == "" then
        TriggerClientEvent("ox_lib:notify", src, {
            title = "Note Required",
            description = "Please add a note before submitting",
            type = "error",
        })
        return
    end

    local publicEmbed = {
        title = "🚗 Vehicle Status Report",
        color = 3447003, -- Blue
        fields = {
            {
                name = "Player",
                value = data.playerName,
                inline = true,
            },
            {
                name = "Vehicle",
                value = vehicleInfo.displayName,
                inline = true,
            },
            {
                name = "Spawncode",
                value = vehicleInfo.spawncode,
                inline = true,
            },
        },
        footer = {
            text = "Vehicle Status Script",
        },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
    }

    if config.enableSpeedAnalytics then
        publicEmbed.fields[#publicEmbed.fields + 1] = {
            name = "Speed Analysis",
            value = ("Baseline: %d mph | Upgraded: %d mph"):format(
                vehicleInfo.baselineSpeed, vehicleInfo.upgradedSpeed
            ),
            inline = true,
        }
    end

    publicEmbed.fields[#publicEmbed.fields + 1] = {
        name = "Note",
        value = note,
        inline = false,
    }

    local staffEmbed = {
        title = "🚨 Staff Vehicle Report",
        color = 16711680, -- Red
        fields = {
            {
                name = "Player Info",
                value = ("%s (ID: %d)\nLicense: `%s`\nDiscord: <@%s>"):format(
                    data.playerName, data.playerId, 
                    license and license:gsub("license:", "") or "N/A",
                    discord and discord:gsub("discord:", "") or "N/A"
                ),
                inline = false,
            },
            {
                name = "Vehicle Info",
                value = ("**Display:** %s\n**Spawncode:** `%s`\n**Model Hash:** `%s`\n**Plate:** `%s`\n**Class:** %s"):format(
                    vehicleInfo.displayName,
                    vehicleInfo.spawncode,
                    vehicleInfo.modelHash,
                    vehicleInfo.plate,
                    vehicleInfo.className
                ),
                inline = false,
            },
        },
        footer = {
            text = "Vehicle Status Script - Staff Report",
        },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
    }

    if config.enableSpeedAnalytics then
        staffEmbed.fields[#staffEmbed.fields + 1] = {
            name = "Speed Analysis",
            value = ("Baseline: %d mph | Full Upgrades: %d mph"):format(
                vehicleInfo.baselineSpeed, vehicleInfo.upgradedSpeed
            ),
            inline = true,
        }
    end

    if mods and mods ~= "" then
        staffEmbed.fields[#staffEmbed.fields + 1] = {
            name = "Modifications",
            value = mods,
            inline = false,
        }
    end

    staffEmbed.fields[#staffEmbed.fields + 1] = {
        name = "Note",
        value = note,
        inline = false,
    }

    if svConfig.publicWebhook and svConfig.publicWebhook ~= "" and svConfig.publicWebhook ~= "YOUR_DISCORD_WEBHOOK_URL_HERE" then
        sendDiscordEmbed(svConfig.publicWebhook, publicEmbed)
    else
        print("[vehiclestatus] Public Discord webhook not configured. Add URL to sv_config.lua")
    end

    if svConfig.staffWebhook and svConfig.staffWebhook ~= "" then
        sendDiscordEmbed(svConfig.staffWebhook, staffEmbed)
    else
        print("[vehiclestatus] Staff Discord webhook not configured. Add URL to sv_config.lua")
    end
end)


RegisterNetEvent("vehiclestatus:server:sendStaffReport", function(data)
end)
