if not BrushToolChooseTileUI then return end

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local TILE_WIDTH, TILE_HEIGHT = 64, 128

local TileSearch = { modes = { "All", "Sheet", "Sprite", "Name" }, matches = {}, firstMatch = {} }

function TileSearch.buildIndex()
	if TileSearch.index then return end
	TileSearch.index = {}
	local sprites = transformIntoKahluaTable(IsoSpriteManager.instance:getNamedMap())
	for spriteName, sprite in pairs(sprites) do
		local sheet, num = string.match(spriteName, "^(.+)_(%d+)$")
		if sheet then
			local props = sprite:getProperties()
			local label = ""
			if props then
				local group = props:has("GroupName") and props:get("GroupName") or nil
				local custom = props:has("CustomName") and props:get("CustomName") or nil
				if group or custom then
					local name = (group and (group .. " ") or "") .. (custom or "")
					label = Translator.getMoveableDisplayName(name) or name
					if label ~= name then label = label .. " (" .. name .. ")" end
				end
			end
			TileSearch.index[sheet] = TileSearch.index[sheet] or {}
			table.insert(TileSearch.index[sheet], { sprite = spriteName, num = tonumber(num), lowerSprite = string.lower(spriteName), lowerLabel = string.lower(label), label = label })
		end
	end
end

function TileSearch.getLabel(spriteName)
	TileSearch.buildIndex()
	local sheet = string.match(spriteName, "^(.+)_%d+$")
	for _, tile in ipairs(sheet and TileSearch.index[sheet] or {}) do
		if tile.sprite == spriteName then return tile.label end
	end
	return ""
end

function TileSearch.matchTiles(sheet, text, mode)
	local tiles = TileSearch.index and TileSearch.index[sheet]
	if not tiles then return false end
	local found = false
	for _, tile in ipairs(tiles) do
		local hit = ((mode == "All" or mode == "Sprite") and string.find(tile.lowerSprite, text, 1, true))
			or ((mode == "All" or mode == "Name") and tile.lowerLabel ~= "" and string.find(tile.lowerLabel, text, 1, true))
		if hit then
			TileSearch.matches[tile.sprite] = true
			if not TileSearch.firstMatch[sheet] or tile.num < TileSearch.firstMatch[sheet] then TileSearch.firstMatch[sheet] = tile.num end
			found = true
		end
	end
	return found
end

local function blankText() return "" end

local MAX_TILES = 2048
local sessionState

function BrushToolTilePickerList:getColumns()
	local scrollWidth = self.vscroll and self.vscroll:getWidth() or 0
	return math.max(1, math.floor((self:getWidth() - scrollWidth) / TILE_WIDTH))
end

function BrushToolTilePickerList:refreshTiles()
	local columns = self:getColumns()
	if self.cachedSheet == self.imageName and self.cachedColumns == columns then return end
	self.cachedSheet, self.cachedColumns = self.imageName, columns
	self.tiles = {}
	self.posToTileNameTable = {}
	if not self.imageName then return end
	for index = 0, MAX_TILES - 1 do
		local tileName = self.imageName .. "_" .. index
		local texture = getTexture(tileName)
		if texture then
			local r, c = math.floor(index / columns) + 1, (index % columns) + 1
			self.posToTileNameTable[r] = self.posToTileNameTable[r] or {}
			self.posToTileNameTable[r][c] = tileName
			table.insert(self.tiles, { name = tileName, texture = texture, r = r, c = c })
		end
	end
end

function BrushToolTilePickerList:render()
	ISPanel.render(self)
	self:setStencilRect(0, 0, self:getWidth(), self:getHeight())
	self:refreshTiles()

	local scale = TILE_WIDTH / 128
	local top = -self:getYScroll()
	local bottom = top + self:getHeight()
	local maxRow = 1
	for _, tile in ipairs(self.tiles) do
		local tileY = (tile.r - 1) * TILE_HEIGHT
		if tileY + TILE_HEIGHT >= top and tileY <= bottom then
			local texture = tile.texture
			self:drawTextureScaled(texture, (tile.c - 1) * TILE_WIDTH + texture:getOffsetX() * scale, tileY + texture:getOffsetY() * scale, texture:getWidth() * scale, texture:getHeight() * scale, 1.0, 1.0, 1.0, 1.0)
		end
		maxRow = math.max(maxRow, tile.r)
	end
	self:setScrollHeight(maxRow * TILE_HEIGHT)
	if self.pendingYScroll then
		self:setYScroll(self.pendingYScroll)
		self.pendingYScroll = nil
	end

	if self.imageName then self:renderSearchOverlay() end
	self:clearStencilRect()
end

function BrushToolTilePickerList:getTileAt(x, y)
	local row = self.posToTileNameTable[math.floor(y / TILE_HEIGHT) + 1]
	return row and row[math.floor(x / TILE_WIDTH) + 1]
end

function BrushToolTilePickerList:onMouseDown(x, y)
	local tileName = self:getTileAt(x, y)
	if not tileName then return end
	getCell():setDrag(ISBrushToolTileCursor:new(tileName, tileName, self.character), self.character:getPlayerNum())
end

function BrushToolChooseTileUI:scrollToFirstMatch(sheet)
	local num = sheet and TileSearch.firstMatch[sheet]
	self.tilesList.pendingYScroll = num and -math.floor(num / self.tilesList:getColumns()) * TILE_HEIGHT or 0
end

local BrushToolChooseTileUI_new = BrushToolChooseTileUI.new
function BrushToolChooseTileUI:new(x, y, width, height, character)
	if sessionState then x, y, width, height = sessionState.x, sessionState.y, sessionState.width, sessionState.height end
	local o = BrushToolChooseTileUI_new(self, x, y, width, height, character)
	o:setResizable(true)
	o.minimumWidth = 300 + TILE_WIDTH * 2
	o.minimumHeight = 300
	return o
end

local BrushToolChooseTileUI_createChildren = BrushToolChooseTileUI.createChildren
function BrushToolChooseTileUI:createChildren()
	BrushToolChooseTileUI_createChildren(self)
	local comboWidth = 80
	self.searchEntryBox:setWidth(self.imageList:getWidth() - comboWidth)
	self.searchEntryBox:setTooltip("Search by tile sheet, sprite name (e.g. fixtures_bathroom_01_24) or tile name (e.g. Fridge)")
	self.searchMode = ISComboBox:new(self.searchEntryBox:getRight(), self.searchEntryBox:getY(), comboWidth, self.searchEntryBox:getHeight(), self, BrushToolChooseTileUI.onSearchModeChange)
	self.searchMode:initialise()
	for _, mode in ipairs(TileSearch.modes) do self.searchMode:addOption(mode) end
	self:addChild(self.searchMode)
	self.imageList:setHeight(self.height - self.imageList:getY() - self:resizeWidgetHeight())
	self.tilesList:setHeight(self.height - self.tilesList:getY() - self:resizeWidgetHeight())
	if sessionState then self:restoreSessionState() end
end

function BrushToolChooseTileUI:restoreSessionState()
	self.searchEntryBox:setText(sessionState.search)
	self.searchMode.selected = sessionState.mode
	self:populateList()
	for index, listItem in ipairs(self.imageList.items) do
		if listItem.item == sessionState.sheet then
			self.imageList.selected = index
			self.imageList:ensureVisible(index)
			self.tilesList.imageName = listItem.item
			self.tilesList.pendingYScroll = sessionState.tileScroll
		end
	end
end

local BrushToolChooseTileUI_close = BrushToolChooseTileUI.close
function BrushToolChooseTileUI:close()
	sessionState = {
		x = self:getX(), y = self:getY(), width = self:getWidth(), height = self:getHeight(),
		search = self.searchEntryBox:getInternalText(),
		mode = self.searchMode.selected,
		sheet = self.tilesList.imageName,
		tileScroll = self.tilesList:getYScroll(),
	}
	BrushToolChooseTileUI_close(self)
end

function BrushToolChooseTileUI:onSearchModeChange()
	self:populateList()
end

local BrushToolChooseTileUI_populateList = BrushToolChooseTileUI.populateList
function BrushToolChooseTileUI:populateList()
	local entry = self.searchEntryBox
	local text = string.lower(string.trim(entry:getInternalText()))
	local mode = self.searchMode and self.searchMode:getOptionText(self.searchMode.selected) or "All"
	TileSearch.matches, TileSearch.firstMatch, TileSearch.text = {}, {}, text

	entry.getInternalText = blankText
	BrushToolChooseTileUI_populateList(self)
	entry.getInternalText = nil

	local list = self.imageList
	if text ~= "" then
		if mode ~= "Sheet" then TileSearch.buildIndex() end
		local items = list.items
		list:clear()
		for _, listItem in ipairs(items) do
			local sheetHit = (mode == "All" or mode == "Sheet") and string.find(string.lower(listItem.text), text, 1, true)
			local tileHit = mode ~= "Sheet" and TileSearch.matchTiles(listItem.item, text, mode)
			if sheetHit and mode == "All" then
				for _, tile in ipairs(TileSearch.index[listItem.item] or {}) do TileSearch.matches[tile.sprite] = nil end
				TileSearch.firstMatch[listItem.item] = nil
			end
			if sheetHit or tileHit then list:addItem(listItem.text, listItem.item) end
		end
	end
	list:setScrollHeight(#list.items * list.itemheight)
	list:setYScroll(0)
	if #list.items > 0 then
		list.selected = 1
		self.tilesList.imageName = list.items[1].item
		self:scrollToFirstMatch(list.items[1].item)
	end
end

local BrushToolChooseTileUI_onSelectImage = BrushToolChooseTileUI.onSelectImage
function BrushToolChooseTileUI.onSelectImage(target, item)
	BrushToolChooseTileUI_onSelectImage(target, item)
	if BrushToolChooseTileUI.instance then BrushToolChooseTileUI.instance:scrollToFirstMatch(item) end
end

function BrushToolTilePickerList:renderSearchOverlay()
	if TileSearch.text and TileSearch.text ~= "" then
		for _, tile in ipairs(self.tiles) do
			if TileSearch.matches[tile.name] then
				local x, y = (tile.c - 1) * TILE_WIDTH, (tile.r - 1) * TILE_HEIGHT
				self:drawRectBorder(x, y, TILE_WIDTH, TILE_HEIGHT, 1, 0.2, 1, 0.2)
				self:drawRectBorder(x + 1, y + 1, TILE_WIDTH - 2, TILE_HEIGHT - 2, 1, 0.2, 1, 0.2)
			end
		end
	end

	if not self:isMouseOver() then return end
	local mouseX, mouseY = self:getMouseX(), self:getMouseY()
	local spriteName = self:getTileAt(mouseX, mouseY)
	if not spriteName then return end
	self:drawRectBorder(math.floor(mouseX / TILE_WIDTH) * TILE_WIDTH, math.floor(mouseY / TILE_HEIGHT) * TILE_HEIGHT, TILE_WIDTH, TILE_HEIGHT, 0.6, 1, 1, 1)
	if self.hoverSprite ~= spriteName then
		self.hoverSprite = spriteName
		self.hoverLabel = TileSearch.getLabel(spriteName)
	end
	local lines = self.hoverLabel ~= "" and 2 or 1
	local width = getTextManager():MeasureStringX(UIFont.Small, spriteName)
	if lines == 2 then width = math.max(width, getTextManager():MeasureStringX(UIFont.Small, self.hoverLabel)) end
	width = width + 8
	local height = lines * FONT_HGT_SMALL + 4
	local x = math.max(0, math.min(mouseX + 16, self:getWidth() - width - 16))
	local y = mouseY + 16
	self:drawRect(x, y, width, height, 0.85, 0, 0, 0)
	self:drawRectBorder(x, y, width, height, 1, 0.4, 0.4, 0.4)
	self:drawText(spriteName, x + 4, y + 2, 1, 1, 1, 1, UIFont.Small)
	if lines == 2 then self:drawText(self.hoverLabel, x + 4, y + 2 + FONT_HGT_SMALL, 0.7, 0.9, 1, 1, UIFont.Small) end
end
