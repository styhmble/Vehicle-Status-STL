local config = require "sv_config"
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
    
    local vehicleInfo = data.vehicleInfo
    local mods = data.mods
    local embed = {
        title = "🚗 Vehicle Status Report",
        color = 3447003, -- Blue
        fields = {
            {
                name = "Player Info",
                value = ("%s (ID: %d)"):format(data.playerName, data.playerId),
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
            {
                name = "Model Hash",
                value = tostring(vehicleInfo.modelHash),
                inline = true,
            },
            {
                name = "Speed Analysis",
                value = ("Baseline: %d mph\nFull Upgrades: %d mph"):format(
                    vehicleInfo.baselineSpeed, vehicleInfo.upgradedSpeed
                ),
                inline = true,
            },
            {
                name = "Vehicle Class",
                value = vehicleInfo.className,
                inline = true,
            },
            {
                name = "Plate",
                value = vehicleInfo.plate,
                inline = true,
            },
            {
                name = "Modifications",
                value = mods,
                inline = false,
            },
        },
        footer = {
            text = "Vehicle Status Script",
        },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
    }

    if config.discordWebhook and config.discordWebhook ~= "" and config.discordWebhook ~= "YOUR_DISCORD_WEBHOOK_URL_HERE" then
        sendDiscordEmbed(config.discordWebhook, embed)
    end
end)