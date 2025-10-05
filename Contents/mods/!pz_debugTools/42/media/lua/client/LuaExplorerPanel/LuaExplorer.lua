--[[

This file defines the main Lua Explorer window which will hold multiple tabs for different file views.

At the end of the file are functions used inside InitToolBar to create the ISEquippedItem button for toggling the Lua Explorer window.

]]


local AUD = require "InitToolBar"
local LuaExplorerTab = require "LuaExplorerPanel/LuaExplorerTab"

AUD.LuaExplorer = {}

---@class LuaExplorer : ISTabPanel
local LuaExplorer = ISTabPanel:derive("LuaExplorer")
function LuaExplorer:RestoreLayout(name, layout)
    ISLayoutManager.DefaultRestoreWindow(self, layout)
end

function LuaExplorer:SaveLayout(name, layout)
    ISLayoutManager.DefaultSaveWindow(self, layout)
    ISLayoutManager.SaveWindowVisible(self, layout)
end

function LuaExplorer:initialise()
    ISTabPanel.initialise(self)

    self:setAnchorBottom(true)
    self:setAnchorRight(true)
    self.target = self
    self:setEqualTabWidth(true)
    self:setCenterTabs(true)
    AUD.luaExplorerWindow = self:wrapInCollapsableWindow("Lua explorer")
    
    local closeFunc = function(obj)
        ISCollapsableWindow.close(obj)
        AUD.luaExplorerWindow:setRemoved(true)
        AUD.LuaExplorerPanel.toolbarButton:setImage(AUD.LuaExplorerPanel.texture_Off)
    end
    
    AUD.luaExplorerWindow.close = closeFunc
    AUD.luaExplorerWindow.closeButton.onmousedown = closeFunc
    AUD.luaExplorerWindow:setResizable(true)

    -- Favorite tab
    AUD.LuaExplorer.favTab = LuaExplorerTab:new(0, 48, AUD.luaExplorerWindow:getWidth(), AUD.luaExplorerWindow:getHeight() - AUD.luaExplorerWindow.nested.tabHeight)
    AUD.LuaExplorer.favTab:initialise("FAV")
    AUD.luaExplorerWindow.nested:addView("Favorite", AUD.LuaExplorer.favTab)

    -- Mods tab
    AUD.LuaExplorer.modTab = LuaExplorerTab:new(0, 48, AUD.luaExplorerWindow:getWidth(), AUD.luaExplorerWindow:getHeight() - AUD.luaExplorerWindow.nested.tabHeight)
    AUD.LuaExplorer.modTab:initialise("MOD")
    AUD.luaExplorerWindow.nested:addView("Mods", AUD.LuaExplorer.modTab)

    -- All tab
    AUD.LuaExplorer.allTab = LuaExplorerTab:new(0, 48, AUD.luaExplorerWindow:getWidth(), AUD.luaExplorerWindow:getHeight() - AUD.luaExplorerWindow.nested.tabHeight)
    AUD.LuaExplorer.allTab:initialise("ALL")
    AUD.luaExplorerWindow.nested:addView("All", AUD.LuaExplorer.allTab)

    AUD.luaExplorerWindow:addToUIManager()
    AUD.LuaExplorerPanel.toolbarButton:setImage(AUD.LuaExplorerPanel.texture_On)

    --ISLayoutManager.RegisterWindow('LuaExplorer', LuaExplorer, self)
end



---LuaExplorer ISEquippedItem button creation functions
AUD.LuaExplorerPanel = {}
AUD.LuaExplorerPanel.texture_On = getTexture("media/textures/_LuaExplorer_On.png")
AUD.LuaExplorerPanel.texture_Off = getTexture("media/textures/_LuaExplorer_Off.png")

local function explorerWindowToggle()
    if AUD.luaExplorerWindow and AUD.luaExplorerWindow:getIsVisible() then
        AUD.luaExplorerWindow:close()
    else
        AUD.luaFileExplorer = LuaExplorer:new(100, 100, 500, 300)
        AUD.luaFileExplorer:initialise()
	end
end

function AUD.LuaExplorerPanel.explorerButton()
    AUD.setNewButton(ISButton, AUD.LuaExplorerPanel, explorerWindowToggle)
end



