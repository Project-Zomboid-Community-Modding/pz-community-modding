require("AUD/Init")
AUD.TeleportPanel = {}

AUD.TeleportPanel.lastX = -1
AUD.TeleportPanel.lastY = -1
AUD.TeleportPanel.lastWidth = -1
AUD.TeleportPanel.lastHeight = -1
AUD.TeleportPanel.lastPosSaved = false

AUD.TeleportPanel.texture_On = getTexture("media/textures/_gps_ON.png")
AUD.TeleportPanel.texture_Off = getTexture("media/textures/_gps_OFF.png")

local function teleportWindowToggle()
    if AUD.teleportWindow and AUD.teleportWindow:getIsVisible() then
        AUD.teleportWindow:close()
    else
        if not AUD.TeleportPanel.lastPosSaved then
            AUD.TeleportPanel.lastX = Core:getInstance():getScreenWidth() - 450
            AUD.TeleportPanel.lastY = 100 
            AUD.TeleportPanel.lastWidth = 400
            AUD.TeleportPanel.lastHeight = 250
            AUD.TeleportPanel.lastPosSaved = true
        end

        AUD.teleport = AUDTeleport:new(AUD.TeleportPanel.lastX, AUD.TeleportPanel.lastY, AUD.TeleportPanel.lastWidth, AUD.TeleportPanel.lastHeight)
        AUD.teleport:initialise()
	end
end

function AUD.TeleportPanel.teleportButton()
    AUD.setNewButton(ISButton, AUD.TeleportPanel, teleportWindowToggle)
end

