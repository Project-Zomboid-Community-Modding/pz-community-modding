local AUD = require "InitToolBar"
local AUDLuaExplorer = require "LuaExplorerPanel/LuaExplorer"

AUD.LuaExplorerPanel = {}
AUD.LuaExplorerPanel.texture_On = getTexture("media/textures/_LuaExplorer_On.png")
AUD.LuaExplorerPanel.texture_Off = getTexture("media/textures/_LuaExplorer_Off.png")

local function explorerWindowToggle()
    if AUD.luaExplorerWindow and AUD.luaExplorerWindow:getIsVisible() then
        AUD.luaExplorerWindow:close()
    else
        AUD.luaFileExplorer = AUDLuaExplorer:new(100, 100, 500, 300)
        AUD.luaFileExplorer:initialise()
	end
end

function AUD.LuaExplorerPanel.explorerButton()
    AUD.setNewButton(ISButton, AUD.LuaExplorerPanel, explorerWindowToggle)
end



