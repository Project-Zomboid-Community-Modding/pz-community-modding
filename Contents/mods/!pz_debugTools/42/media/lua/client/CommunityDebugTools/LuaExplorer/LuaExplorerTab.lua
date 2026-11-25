local AUD = require "CommunityDebugTools/debugToolbar"
local CustomLuaFileExplorerList = require "CommunityDebugTools/LuaExplorer/luaFavorites"
local LuaFiles = require "CommunityDebugTools/Commands/LuaFiles"

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)

---@class LuaExplorerTab : ISPanelJoypad
---@field fileCategory string
---@field fileList CustomLuaFileExplorerList
local LuaExplorerTab = ISPanelJoypad:derive("LuaExplorerTab")

local function getFileSubText(path)
	return (LuaFiles.getModName(path) or "vanilla") .. " / " .. (LuaFiles.getSide(path) or "?")
end

local function isFav(target, path) return AUD.FileExplorer.IndexOfFav(path) ~= nil end
local function isNotFav(target, path) return AUD.FileExplorer.IndexOfFav(path) == nil end

function LuaExplorerTab:initialise(category)
	ISPanelJoypad.initialise(self)

	self.fileCategory = category

	self:instantiate()
	self:setAnchorRight(true)
	self:setAnchorLeft(true)
	self:setAnchorTop(true)
	self:setAnchorBottom(true)
	self:noBackground()

	self.borderColor = {r=0, g=0, b=0, a=0}

	local entryHgt = FONT_HGT_SMALL + 2 * 2
	local buttonText = (self.fileCategory == "FAV" and "Reload All") or (self.fileCategory == "SERVER" and "Refresh") or nil
	local buttonW = buttonText and (getTextManager():MeasureStringX(UIFont.Small, buttonText) + 16) or 0

	self.textEntry = ISTextEntryBox:new("", 0, 2, self.width - buttonW - (buttonText and 4 or 0), entryHgt)
	self.textEntry:initialise()
	self.textEntry:instantiate()
	self.textEntry:setClearButton(true)
	self.textEntry:setAnchorRight(true)
	self.textEntry:setTooltip(self.fileCategory == "SERVER" and "Filter server files (empty lists server mods)" or "Filter")
	self:addChild(self.textEntry)
	self.lastText = ""

	if buttonText then
		local button = ISButton:new(self.width - buttonW, 2, buttonW, entryHgt, buttonText, self, self.fileCategory == "FAV" and self.onReloadAll or self.requestServerList)
		button:initialise()
		button.anchorLeft = false
		button.anchorRight = true
		button.borderColor = {r=1, g=1, b=1, a=0.1}
		self:addChild(button)
	end

	local listY = entryHgt + 6
	self.fileList = CustomLuaFileExplorerList:new(0, listY, self.width, self.height - listY - entryHgt - 4, self)
	self.fileList.anchorRight = true
	self.fileList.anchorBottom = true
	self.fileList:initialise()
	self.fileList:setOnMouseDoubleClick(self, self.onReload)
	self.fileList:setFont(UIFont.Small, 3)
	self:addChild(self.fileList)

	self.fileList:addRowButton("Reload", self.onReload, nil, self.fileCategory == "SERVER" and "Reload on server" or "Reload")
	if self.fileCategory == "FAV" then
		self.fileList:addRowButton("^", self.onButtonUp, nil, "Move up")
		self.fileList:addRowButton("v", self.onButtonDown, nil, "Move down")
		self.fileList:addRowButton("-", self.onButtonRemove, nil, "Remove from favorites")
	elseif self.fileCategory == "ALL" then
		self.fileList:addRowButton("+", self.onButtonAdd, isNotFav, "Add to favorites")
		self.fileList:addRowButton("-", self.onButtonRemove, isFav, "Remove from favorites")
	end

	if self.fileCategory == "SERVER" then
		LuaFiles.onServerList = function(args) self:onServerList(args) end
		self:requestServerList()
	else
		self:fill()
	end
end

function LuaExplorerTab:getFilter()
	return string.trim(self.textEntry:getInternalText() or "")
end

function LuaExplorerTab:setStatus(text)
	AUD.LuaExplorer.statusText = text
end

function LuaExplorerTab:fill()
	local selected = self.fileList.selected
	local yScroll = self.fileList:getYScroll()
	local filter = self:getFilter()
	self.fileList:clear()

	if self.fileCategory == "FAV" then
		for i=1, #AUD.FileExplorer.FavFileList do
			local path = AUD.FileExplorer.FavFileList[i]
			local name = getShortenedFilename(path)
			if LuaFiles.matches(name, filter) then
				self.fileList:addItem(name, path).subText = getFileSubText(path)
			end
		end
	elseif self.fileCategory == "MOD" then
		for _,mod in ipairs(LuaFiles.getMods()) do
			if LuaFiles.matches(mod.name, filter) then
				self.fileList:addItem(mod.name, mod).subText = mod.count .. " files"
			end
		end
	elseif self.fileCategory == "ALL" then
		for i = 0, getLoadedLuaCount() - 1 do
			local path = getLoadedLua(i)
			local name = getShortenedFilename(path)
			if LuaFiles.matches(name, filter) then
				self.fileList:addItem(name, path).subText = getFileSubText(path)
			end
		end
	end

	self.fileList.selected = math.min(selected, #self.fileList.items)
	self.fileList:setYScroll(yScroll)
end

function LuaExplorerTab:requestServerList()
	self.pendingRequest = nil
	self:setStatus("Requesting server file list...")
	LuaFiles.requestServerList(self:getFilter())
end

function LuaExplorerTab:onServerList(args)
	if (args.filter or "") ~= self:getFilter() then return end
	self.fileList:clear()
	for _,mod in ipairs(args.mods or {}) do
		self.fileList:addItem(mod.name, {modAll = mod.name}).subText = mod.count .. " files"
	end
	for _,file in ipairs(args.files or {}) do
		self.fileList:addItem(file.name, {path = file.path}).subText = file.mod or "vanilla"
	end
	if args.filter == "" then
		self:setStatus("Server mods: " .. #self.fileList.items .. " (type to search server files)")
	else
		self:setStatus("Server files: " .. #self.fileList.items .. " shown of " .. (args.total or 0))
	end
end

function LuaExplorerTab:onReload(item)
	if not item then return end
	if self.fileCategory == "SERVER" then
		LuaFiles.onServerReloaded = function(args) self:setStatus("Server reloaded " .. args.count .. " file(s)" .. (args.missing > 0 and (", " .. args.missing .. " not found") or "")) end
		LuaFiles.reloadOnServer({item})
		self:setStatus("Reloading on server...")
		return
	end

	local paths = (self.fileCategory == "MOD" and item.paths) or {item}
	local count, serverCount = LuaFiles.reloadFiles(paths)
	local status = "Reloaded " .. ((self.fileCategory == "MOD" and (item.name .. " (" .. count .. " files)")) or getShortenedFilename(item))
	if serverCount > 0 then
		status = status .. ", " .. serverCount .. " sent to server"
		LuaFiles.onServerReloaded = function(args) self:setStatus(status .. " (server reloaded " .. args.count .. ")") end
	end
	self:setStatus(status)
end

function LuaExplorerTab:onReloadAll()
	local count, serverCount = LuaFiles.reloadFiles(AUD.FileExplorer.FavFileList)
	local status = "Reloaded " .. count .. " favorite file(s)"
	if serverCount > 0 then
		status = status .. ", " .. serverCount .. " sent to server"
		LuaFiles.onServerReloaded = function(args) self:setStatus(status .. " (server reloaded " .. args.count .. ")") end
	end
	self:setStatus(status)
end

function LuaExplorerTab:update()
	ISPanelJoypad.update(self)
	local text = self:getFilter()
	if text ~= self.lastText then
		self.lastText = text
		if self.fileCategory == "SERVER" then
			self.pendingRequest = getTimestampMs() + 400
		else
			self:fill()
		end
	end
	if self.pendingRequest and getTimestampMs() >= self.pendingRequest then
		self:requestServerList()
	end
end

function LuaExplorerTab:render()
	ISPanelJoypad.render(self)
	if AUD.LuaExplorer.statusText then
		self:drawText(AUD.LuaExplorer.statusText, 4, self.fileList:getBottom() + 2, 0.7, 0.7, 0.7, 0.9, UIFont.Small)
	end
end

function LuaExplorerTab:refreshFavorites()
	AUD.LuaExplorer.favTab:fill()
	if AUD.LuaExplorer.allTab then AUD.LuaExplorer.allTab:fill() end
end

function LuaExplorerTab:onButtonAdd(path)
	AUD.FileExplorer.AddFav(path)
	self:setStatus("Added " .. getShortenedFilename(path) .. " to favorites")
	self:refreshFavorites()
end

function LuaExplorerTab:onButtonRemove(path)
	AUD.FileExplorer.RemoveFav(path)
	self:setStatus("Removed " .. getShortenedFilename(path) .. " from favorites")
	self:refreshFavorites()
end

function LuaExplorerTab:moveFav(path, offset)
	AUD.FileExplorer.MoveFav(path, offset)
	self:fill()
	for i,item in ipairs(self.fileList.items) do
		if item.item == path then self.fileList.selected = i self.fileList:ensureVisible(i) end
	end
end

function LuaExplorerTab:onButtonUp(path) self:moveFav(path, -1) end
function LuaExplorerTab:onButtonDown(path) self:moveFav(path, 1) end

return LuaExplorerTab
