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

function BrushToolChooseTileUI:scrollToFirstMatch(sheet)
	local num = sheet and TileSearch.firstMatch[sheet]
	self.tilesList:setYScroll(num and -math.floor(num / 8) * TILE_HEIGHT or 0)
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

local BrushToolTilePickerList_render = BrushToolTilePickerList.render
function BrushToolTilePickerList:render()
	self:setStencilRect(0, 0, self:getWidth(), self:getHeight())
	BrushToolTilePickerList_render(self)
	if self.imageName then self:renderSearchOverlay() end
	self:clearStencilRect()
end

function BrushToolTilePickerList:renderSearchOverlay()
	if TileSearch.text and TileSearch.text ~= "" then
		for r, row in pairs(self.posToTileNameTable) do
			for c, spriteName in pairs(row) do
				if TileSearch.matches[spriteName] then
					self:drawRectBorder((c - 1) * TILE_WIDTH, (r - 1) * TILE_HEIGHT, TILE_WIDTH, TILE_HEIGHT, 1, 0.2, 1, 0.2)
					self:drawRectBorder((c - 1) * TILE_WIDTH + 1, (r - 1) * TILE_HEIGHT + 1, TILE_WIDTH - 2, TILE_HEIGHT - 2, 1, 0.2, 1, 0.2)
				end
			end
		end
	end

	if not self:isMouseOver() then return end
	local mouseX, mouseY = self:getMouseX(), self:getMouseY()
	local c, r = math.floor(mouseX / TILE_WIDTH), math.floor(mouseY / TILE_HEIGHT)
	local row = self.posToTileNameTable[r + 1]
	local spriteName = row and row[c + 1]
	if not spriteName or not getTexture(spriteName) then return end
	if self.hoverSprite ~= spriteName then
		self.hoverSprite = spriteName
		self.hoverLabel = TileSearch.getLabel(spriteName)
	end
	local lines = self.hoverLabel ~= "" and 2 or 1
	local width = getTextManager():MeasureStringX(UIFont.Small, spriteName)
	if lines == 2 then width = math.max(width, getTextManager():MeasureStringX(UIFont.Small, self.hoverLabel)) end
	width = width + 8
	local height = lines * FONT_HGT_SMALL + 4
	local x = math.min(mouseX + 16, self:getWidth() - width - 16)
	local y = mouseY + 16
	self:drawRect(x, y, width, height, 0.85, 0, 0, 0)
	self:drawRectBorder(x, y, width, height, 1, 0.4, 0.4, 0.4)
	self:drawText(spriteName, x + 4, y + 2, 1, 1, 1, 1, UIFont.Small)
	if lines == 2 then self:drawText(self.hoverLabel, x + 4, y + 2 + FONT_HGT_SMALL, 0.7, 0.9, 1, 1, UIFont.Small) end
end
