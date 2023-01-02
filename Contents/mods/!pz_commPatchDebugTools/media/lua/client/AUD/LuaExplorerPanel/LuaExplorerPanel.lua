require("AUD/Init")
AUD.LuaExplorerPanel = {}

AUD.LuaExplorerPanel.lastX = -1
AUD.LuaExplorerPanel.lastY = -1
AUD.LuaExplorerPanel.lastWidth = -1
AUD.LuaExplorerPanel.lastHeight = -1
AUD.LuaExplorerPanel.lastPosSaved = false

AUD.LuaExplorerPanel.texture_Explorer_On = getTexture("media/textures/_LuaExplorer_On.png")
AUD.LuaExplorerPanel.texture_Explorer_Off = getTexture("media/textures/_LuaExplorer_Off.png")

local function explorerWindowToggle()
    if AUD.luaExplorerWindow and AUD.luaExplorerWindow:getIsVisible() then
        AUD.luaExplorerWindow:close();
    else
        if not AUD.LuaExplorerPanel.lastPosSaved then
            AUD.LuaExplorerPanel.lastX = Core:getInstance():getScreenWidth() - 750  --1170
            AUD.LuaExplorerPanel.lastY = Core:getInstance():getScreenHeight() - 324 --  756
            AUD.LuaExplorerPanel.lastWidth = 500
            AUD.LuaExplorerPanel.lastHeight = 300
            AUD.LuaExplorerPanel.lastPosSaved = true
        end

        AUD.luaFileExplorer = AUDLuaExplorer:new(AUD.LuaExplorerPanel.lastX, AUD.LuaExplorerPanel.lastY, AUD.LuaExplorerPanel.lastWidth, AUD.LuaExplorerPanel.lastHeight);
        AUD.luaFileExplorer:initialise();
	end
end

function AUD.LuaExplorerPanel.explorerButton()
    local xMax, yMax = AUD.getNewButtonXY()
	AUD.LuaExplorerPanel.toolbarButton = ISButton:new(xMax, yMax, 48, 48, "", nil, explorerWindowToggle)
	AUD.LuaExplorerPanel.toolbarButton:setImage(AUD.LuaExplorerPanel.texture_Explorer_Off)
	AUD.LuaExplorerPanel.toolbarButton:setDisplayBackground(false)
    AUD.LuaExplorerPanel.toolbarButton.borderColor = {r=1, g=1, b=1, a=0.1}

	ISEquippedItem.instance:addChild(AUD.LuaExplorerPanel.toolbarButton)
    ISEquippedItem.instance:setHeight(ISEquippedItem.instance:getHeight()+AUD.LuaExplorerPanel.toolbarButton:getHeight()+5)
end



