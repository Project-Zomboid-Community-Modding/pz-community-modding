local AUD = require "CommunityDebugTools/debugToolbar"

AUD.TeleportTable = {}
AUD.TeleportPoints = {}
AUD.TeleportFile = "CommunityDebugTeleportPoints.txt"
AUD.TeleportLegacyFile = "AUDTeleportPoints.txt"

AUDTeleport = ISTabPanel:derive("AUDTeleport")

local function round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end

function AUDTeleport.sanitize(text)
	local sanitized = string.gsub(text or "", "[|\r\n]", "")
	return string.trim(sanitized)
end

function AUDTeleport.readLines(fileName)
	local lines = {}
	local readFile = getFileReader(fileName, false)
	if not readFile then return lines end
	local line = readFile:readLine()
	while line do
		table.insert(lines, line)
		line = readFile:readLine()
	end
	readFile:close()
	return lines
end

function AUDTeleport.loadLegacyPoints()
	local points = {}
	local lines = AUDTeleport.readLines(AUD.TeleportLegacyFile)
	local category = ""
	local i = 1
	while i <= #lines do
		if lines[i] == "CATEGORY" then
			category = lines[i+1] or ""
			if category == "All" then category = "" end
			i = i + 2
		else
			local name, x, y, z = lines[i], tonumber(lines[i+1]), tonumber(lines[i+2]), tonumber(lines[i+3])
			i = i + 4
			if name and x and y and z then
				local existing
				for _,point in ipairs(points) do
					if point.name == name and point.x == x and point.y == y and point.z == z then existing = point break end
				end
				if existing then
					if existing.category == "" then existing.category = category end
				else
					table.insert(points, {name = name, x = x, y = y, z = z, category = category})
				end
			end
		end
	end
	return points
end

function AUDTeleport.loadPoints()
	local points = {}
	local lines = AUDTeleport.readLines(AUD.TeleportFile)
	if #lines == 0 then
		AUD.TeleportPoints = AUDTeleport.loadLegacyPoints()
		if #AUD.TeleportPoints > 0 then AUDTeleport.savePoints() end
		return
	end
	for _,line in ipairs(lines) do
		local parts = string.split(line, "\\|")
		local x, y, z = tonumber(parts[2]), tonumber(parts[3]), tonumber(parts[4])
		if parts[1] and x and y and z then
			table.insert(points, {name = parts[1], x = x, y = y, z = z, category = parts[5] or ""})
		end
	end
	AUD.TeleportPoints = points
end

function AUDTeleport.savePoints()
	local writeFile = getFileWriter(AUD.TeleportFile, true, false)
	for _,point in ipairs(AUD.TeleportPoints) do
		writeFile:write(AUDTeleport.sanitize(point.name) .. "|" .. point.x .. "|" .. point.y .. "|" .. point.z .. "|" .. AUDTeleport.sanitize(point.category) .. "\r\n")
	end
	writeFile:close()
end

function AUDTeleport.getCategories()
	local categories = {}
	local seen = {}
	for _,point in ipairs(AUD.TeleportPoints) do
		if point.category ~= "" and not seen[point.category] then
			seen[point.category] = true
			table.insert(categories, point.category)
		end
	end
	table.sort(categories, function(a, b) return string.lower(a) < string.lower(b) end)
	return categories
end

function AUDTeleport.indexOf(point)
	for i,p in ipairs(AUD.TeleportPoints) do
		if p == point then return i end
	end
end

function AUDTeleport.makePointAt(character, category, name)
	local square = character:getCurrentSquare()
	local room = square and square:getRoom()
	return {
		name = name or (room and room:getName()) or ("Point " .. (#AUD.TeleportPoints + 1)),
		x = round(character:getX(), 2),
		y = round(character:getY(), 2),
		z = round(character:getZ(), 2),
		category = category or "",
	}
end

function AUDTeleport.addPoint(point)
	point.name = AUDTeleport.sanitize(point.name)
	point.category = AUDTeleport.sanitize(point.category)
	if point.category == "All" then point.category = "" end
	table.insert(AUD.TeleportPoints, point)
	AUDTeleport.onPointsChanged()
end

function AUDTeleport.updatePoint(point, values)
	point.name = AUDTeleport.sanitize(values.name)
	point.x, point.y, point.z = values.x, values.y, values.z
	point.category = AUDTeleport.sanitize(values.category)
	if point.category == "All" then point.category = "" end
	AUDTeleport.onPointsChanged()
end

function AUDTeleport.removePoint(point)
	local index = AUDTeleport.indexOf(point)
	if not index then return end
	table.remove(AUD.TeleportPoints, index)
	AUDTeleport.onPointsChanged()
end

function AUDTeleport.swapPoints(pointA, pointB)
	local a, b = AUDTeleport.indexOf(pointA), AUDTeleport.indexOf(pointB)
	if not a or not b then return end
	AUD.TeleportPoints[a], AUD.TeleportPoints[b] = pointB, pointA
	AUDTeleport.onPointsChanged()
end

function AUDTeleport.onPointsChanged()
	AUDTeleport.savePoints()
	if AUD.teleport and AUD.teleportWindow and AUD.teleportWindow:getIsVisible() then AUD.teleport:refresh() end
end

function AUDTeleport.teleportTo(x, y, z)
	local player = getSpecificPlayer(0)
	if not player then return end
	if isClient() then
		SendCommandToServer("/teleportto " .. x .. "," .. y .. "," .. z)
	else
		player:teleportTo(x, y, z)
	end
end

function AUDTeleport:RestoreLayout(name, layout)
	ISLayoutManager.DefaultRestoreWindow(self, layout)
end

function AUDTeleport:SaveLayout(name, layout)
	ISLayoutManager.DefaultSaveWindow(self, layout)
	ISLayoutManager.SaveWindowVisible(self, layout)
end

function AUDTeleport:initialise()
	ISTabPanel.initialise(self)

	self:setAnchorBottom(true)
	self:setAnchorRight(true)
	self.target = self
	self:setEqualTabWidth(false)
	self:setCenterTabs(false)
	AUD.teleportWindow = self:wrapInCollapsableWindow("Teleport")

	local closeFunc = function(obj)
		ISCollapsableWindow.close(obj)
		AUD.teleportWindow:setRemoved(true)
		AUD.TeleportPanel.toolbarButton:setImage(AUD.TeleportPanel.texture_Off)
	end

	AUD.teleportWindow.close = closeFunc
	AUD.teleportWindow.closeButton.onmousedown = closeFunc
	AUD.teleportWindow:setResizable(true)

	AUD.TeleportTable = {}
	AUDTeleport.loadPoints()
	self:createTab("All", "All")
	if isClient() then AUD.TeleportPlayersTab = self:createTab("Players", nil, "PLAYERS") end
	self:refresh()

	AUD.teleportWindow:addToUIManager()
	AUD.TeleportPanel.toolbarButton:setImage(AUD.TeleportPanel.texture_On)
end

function AUDTeleport:createTab(name, category, mode)
	local tab = AUDTeleportTab:new(0, self.tabHeight, self:getWidth(), self:getHeight() - self.tabHeight)
	tab:initialise(category, mode)
	self:addView(name, tab)
	if category then AUD.TeleportTable[category] = tab end
	return tab
end

function AUDTeleport:refresh()
	local wanted = {All = true}
	for _,category in ipairs(AUDTeleport.getCategories()) do
		wanted[category] = true
		if not AUD.TeleportTable[category] then self:createTab(category, category) end
	end

	local toRemove = {}
	for category,tab in pairs(AUD.TeleportTable) do
		if not wanted[category] then table.insert(toRemove, category) end
	end
	for _,category in ipairs(toRemove) do
		local tab = AUD.TeleportTable[category]
		local wasActive = self:getActiveView() == tab
		self:removeView(tab)
		AUD.TeleportTable[category] = nil
		if wasActive then self:activateView("All") end
	end

	for _,tab in pairs(AUD.TeleportTable) do tab:fill() end
end
