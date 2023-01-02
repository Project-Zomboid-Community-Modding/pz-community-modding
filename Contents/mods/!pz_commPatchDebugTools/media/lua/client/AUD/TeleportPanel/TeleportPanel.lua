require("AUD/Init")
AUD.TeleportPanel = {}

AUD.TeleportPanel.lastX = -1
AUD.TeleportPanel.lastY = -1
AUD.TeleportPanel.lastWidth = -1
AUD.TeleportPanel.lastHeight = -1
AUD.TeleportPanel.lastPosSaved = false

AUD.TeleportPanel.texture_teleport_On = getTexture("media/textures/_gps_ON.png")
AUD.TeleportPanel.texture_teleport_Off = getTexture("media/textures/_gps_OFF.png")

local function teleportWindowToggle()
    if AUD.teleportWindow and AUD.teleportWindow:getIsVisible() then
        AUD.teleportWindow:close();
    else
        if not AUD.TeleportPanel.lastPosSaved then
            AUD.TeleportPanel.lastX = Core:getInstance():getScreenWidth() - 450
            AUD.TeleportPanel.lastY = 100 
            AUD.TeleportPanel.lastWidth = 400
            AUD.TeleportPanel.lastHeight = 250
            AUD.TeleportPanel.lastPosSaved = true
        end

        AUD.teleport = AUDTeleport:new(AUD.TeleportPanel.lastX, AUD.TeleportPanel.lastY, AUD.TeleportPanel.lastWidth, AUD.TeleportPanel.lastHeight);
        AUD.teleport:initialise();
	end
end

function AUD.TeleportPanel.teleportButton()
    local xMax, yMax = AUD.getNewButtonXY()
	AUD.TeleportPanel.toolbarButton = ISButton:new(xMax, yMax, 48, 48, "", nil, teleportWindowToggle)
	AUD.TeleportPanel.toolbarButton:setImage(AUD.TeleportPanel.texture_teleport_Off)
	AUD.TeleportPanel.toolbarButton:setDisplayBackground(false)
    AUD.TeleportPanel.toolbarButton.borderColor = {r=1, g=1, b=1, a=0.1}

	ISEquippedItem.instance:addChild(AUD.TeleportPanel.toolbarButton)
    ISEquippedItem.instance:setHeight(ISEquippedItem.instance:getHeight()+AUD.TeleportPanel.toolbarButton:getHeight()+5)
end

