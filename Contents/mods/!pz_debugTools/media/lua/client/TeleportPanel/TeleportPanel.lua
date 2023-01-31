require "InitToolBar"

AUD.TeleportPanel = {}
AUD.TeleportPanel.texture_On = getTexture("media/textures/_gps_ON.png")
AUD.TeleportPanel.texture_Off = getTexture("media/textures/_gps_OFF.png")

local function teleportWindowToggle()
    if AUD.teleportWindow and AUD.teleportWindow:getIsVisible() then
        AUD.teleportWindow:close()
    else
        AUD.teleport = AUDTeleport:new(100, 100, 400, 250)
        AUD.teleport:initialise()
	end
end

function AUD.TeleportPanel.teleportButton()
    AUD.setNewButton(ISButton, AUD.TeleportPanel, teleportWindowToggle)
end

