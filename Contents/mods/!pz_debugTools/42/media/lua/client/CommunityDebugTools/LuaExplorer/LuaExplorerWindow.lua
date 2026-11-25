local AUD = require "CommunityDebugTools/debugToolbar"
local LuaExplorerTab = require "CommunityDebugTools/LuaExplorer/LuaExplorerTab"

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

function LuaExplorer:addTab(name, category)
	local tab = LuaExplorerTab:new(0, self.tabHeight, self:getWidth(), self:getHeight() - self.tabHeight)
	tab:initialise(category)
	self:addView(name, tab)
	return tab
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

	AUD.LuaExplorer.favTab = self:addTab("Favorite", "FAV")
	AUD.LuaExplorer.modTab = self:addTab("Mods", "MOD")
	AUD.LuaExplorer.allTab = self:addTab("All", "ALL")
	if isClient() then AUD.LuaExplorer.serverTab = self:addTab("Server", "SERVER") end

	AUD.luaExplorerWindow:addToUIManager()
	AUD.LuaExplorerPanel.toolbarButton:setImage(AUD.LuaExplorerPanel.texture_On)
end



---LuaExplorer ISEquippedItem button creation functions
AUD.LuaExplorerPanel = {}
AUD.LuaExplorerPanel.texture_On = getTexture("media/textures/_LuaExplorer_On.png")
AUD.LuaExplorerPanel.texture_Off = getTexture("media/textures/_LuaExplorer_Off.png")

local function explorerWindowToggle()
	if AUD.luaExplorerWindow and AUD.luaExplorerWindow:getIsVisible() then
		AUD.luaExplorerWindow:close()
	else
		AUD.luaFileExplorer = LuaExplorer:new(100, 100, 560, 340)
		AUD.luaFileExplorer:initialise()
	end
end

function AUD.LuaExplorerPanel.explorerButton()
	AUD.setNewButton(ISButton, AUD.LuaExplorerPanel, explorerWindowToggle)
end
