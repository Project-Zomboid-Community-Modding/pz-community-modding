require("AUD/Init")
AUD.LuaExplorerPanel = {}

AUD.LuaExplorerPanel.lastX = -1
AUD.LuaExplorerPanel.lastY = -1
AUD.LuaExplorerPanel.lastWidth = -1
AUD.LuaExplorerPanel.lastHeight = -1
AUD.LuaExplorerPanel.lastPosSaved = false

AUD.LuaExplorerPanel.texture_On = getTexture("media/textures/_LuaExplorer_On.png")
AUD.LuaExplorerPanel.texture_Off = getTexture("media/textures/_LuaExplorer_Off.png")

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
    AUD.setNewButton(ISButton, AUD.LuaExplorerPanel, explorerWindowToggle)
end



