local AUD = require "CommunityDebugTools/debugToolbar"

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)

AUDTeleportTab = ISPanelJoypad:derive("AUDTeleportTab")

local function addToolbarButton(tab, x, w, h, text, onClick, tooltip)
	local button = ISButton:new(x, 2, w, h, text, tab, onClick)
	button:initialise()
	button.anchorLeft = false
	button.anchorRight = true
	button.borderColor = {r=1, g=1, b=1, a=0.1}
	if tooltip then button:setTooltip(tooltip) end
	tab:addChild(button)
	return button
end

function AUDTeleportTab:initialise(category, mode)
	ISPanelJoypad.initialise(self)

	self.pointCategory = category
	self.mode = mode
	self.visiblePoints = {}

	self:instantiate()
	self:setAnchorRight(true)
	self:setAnchorLeft(true)
	self:setAnchorTop(true)
	self:setAnchorBottom(true)
	self:noBackground()

	self.borderColor = {r=0, g=0, b=0, a=0}

	local entryHgt = FONT_HGT_SMALL + 2 * 2
	local buttonsW = 0

	if self.mode == "PLAYERS" then
		buttonsW = 70
		addToolbarButton(self, self.width - 70, 68, entryHgt, "Refresh", self.fill)
	else
		buttonsW = 150
		addToolbarButton(self, self.width - 150, 72, entryHgt, "Add Here", self.onAddHere, "Save your current position to this tab")
		addToolbarButton(self, self.width - 76, 74, entryHgt, "Add...", self.onAddCustom, "Add a point with custom coordinates")
	end

	self.textEntry = ISTextEntryBox:new("", 0, 2, self.width - buttonsW - 4, entryHgt)
	self.textEntry:initialise()
	self.textEntry:instantiate()
	self.textEntry:setClearButton(true)
	self.textEntry:setAnchorRight(true)
	self.textEntry:setTooltip("Filter")
	self:addChild(self.textEntry)
	self.lastText = ""

	local listY = entryHgt + 6
	self.fileList = TeleportPointList:new(0, listY, self.width, self.height - listY - entryHgt, self)
	self.fileList.anchorRight = true
	self.fileList.anchorBottom = true
	self.fileList:initialise()
	self.fileList:setOnMouseDoubleClick(self.fileList, TeleportPointList.onMouseDoubleClickFile)
	self.fileList:setFont(UIFont.Small, 3)
	self:addChild(self.fileList)

	if self.mode == "PLAYERS" then
		self.fileList:addRowButton("Go", self.onGo, nil, "Teleport to player")
		self.fileList:addRowButton("Save", self.onSavePlayer, nil, "Save player's position as a point")
	else
		self.fileList:addRowButton("Go", self.onGo, nil, "Teleport")
		self.fileList:addRowButton("^", self.onMoveUp, nil, "Move up")
		self.fileList:addRowButton("v", self.onMoveDown, nil, "Move down")
		self.fileList:addRowButton("Edit", self.onEdit, nil, "Edit point")
		self.fileList:addRowButton("X", self.onRemove, nil, "Remove point")
	end

	self:fill()
end

function AUDTeleportTab:getFilter()
	return string.lower(string.trim(self.textEntry:getInternalText() or ""))
end

function AUDTeleportTab:matches(text)
	local filter = self:getFilter()
	return filter == "" or string.find(string.lower(text or ""), filter, 1, true) ~= nil
end

function AUDTeleportTab:fill()
	local selected = self.fileList.selected
	local yScroll = self.fileList:getYScroll()
	self.fileList:clear()
	self.visiblePoints = {}

	if self.mode == "PLAYERS" then
		local localPlayer = getSpecificPlayer(0)
		local players = getOnlinePlayers()
		for i = 0, (players and players:size() or 0) - 1 do
			local player = players:get(i)
			if player ~= localPlayer and self:matches(player:getUsername()) then
				local item = self.fileList:addItem(player:getUsername(), player)
				item.subText = math.floor(player:getX()) .. ", " .. math.floor(player:getY()) .. ", " .. math.floor(player:getZ())
			end
		end
		self.lastFill = getTimestampMs()
	else
		for _,point in ipairs(AUD.TeleportPoints) do
			if (self.pointCategory == "All" or point.category == self.pointCategory) and (self:matches(point.name) or self:matches(point.category)) then
				table.insert(self.visiblePoints, point)
				local item = self.fileList:addItem(point.name, point)
				local coords = math.floor(point.x) .. ", " .. math.floor(point.y) .. ", " .. math.floor(point.z)
				if self.pointCategory == "All" and point.category ~= "" then coords = "[" .. point.category .. "]  " .. coords end
				item.subText = coords
			end
		end
	end

	self.fileList.selected = math.min(selected, #self.fileList.items)
	self.fileList:setYScroll(yScroll)
end

function AUDTeleportTab:update()
	ISPanelJoypad.update(self)
	local text = self:getFilter()
	if text ~= self.lastText then
		self.lastText = text
		self:fill()
	elseif self.mode == "PLAYERS" and self:isReallyVisible() and getTimestampMs() - (self.lastFill or 0) > 1000 then
		self:fill()
	end
end

function AUDTeleportTab:selectPoint(point)
	for i,item in ipairs(self.fileList.items) do
		if item.item == point then
			self.fileList.selected = i
			self.fileList:ensureVisible(i)
			return
		end
	end
end

function AUDTeleportTab:getCategoryForNewPoints()
	if self.pointCategory == "All" then return "" end
	return self.pointCategory
end

function AUDTeleportTab:onAddHere()
	local player = getSpecificPlayer(0)
	if not player then return end
	local point = AUDTeleport.makePointAt(player, self:getCategoryForNewPoints())
	AUDTeleport.addPoint(point)
	self:selectPoint(point)
end

function AUDTeleportTab:onAddCustom()
	local player = getSpecificPlayer(0)
	local defaults = player and AUDTeleport.makePointAt(player, self:getCategoryForNewPoints()) or {category = self:getCategoryForNewPoints()}
	AddPointPanel.open(nil, defaults)
end

function AUDTeleportTab:onGo(target)
	TeleportPointList.onMouseDoubleClickFile(self.fileList, target)
end

function AUDTeleportTab:onSavePlayer(player)
	AddPointPanel.open(nil, AUDTeleport.makePointAt(player, "", player:getUsername()))
end

function AUDTeleportTab:movePoint(point, offset)
	for i,visible in ipairs(self.visiblePoints) do
		if visible == point then
			local other = self.visiblePoints[i + offset]
			if other then
				AUDTeleport.swapPoints(point, other)
				self:selectPoint(point)
			end
			return
		end
	end
end

function AUDTeleportTab:onMoveUp(point) self:movePoint(point, -1) end
function AUDTeleportTab:onMoveDown(point) self:movePoint(point, 1) end
function AUDTeleportTab:onEdit(point) AddPointPanel.open(point) end
function AUDTeleportTab:onRemove(point) AUDTeleport.removePoint(point) end
