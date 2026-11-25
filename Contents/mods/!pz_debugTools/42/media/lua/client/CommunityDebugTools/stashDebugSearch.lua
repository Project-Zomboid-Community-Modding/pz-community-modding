if not StashDebug then return end

local StashDebug_initialise = StashDebug.initialise
function StashDebug:initialise()
	StashDebug_initialise(self)
	local list = self.datas
	local height = getTextManager():getFontHeight(UIFont.Small) + 6
	self.searchEntryBox = ISTextEntryBox:new("", list:getX(), list:getY(), list:getWidth(), height)
	self.searchEntryBox:initialise()
	self.searchEntryBox:instantiate()
	self.searchEntryBox.target = self
	self.searchEntryBox.onTextChangeFunction = StashDebug.onSearchChange
	self.searchEntryBox:setTooltip("Search stashes by name")
	self:addChild(self.searchEntryBox)
	list:setY(list:getY() + height + 5)
	list:setHeight(list:getHeight() - height - 5)
end

function StashDebug:onSearchChange()
	self:populateList()
end

local StashDebug_populateList = StashDebug.populateList
function StashDebug:populateList()
	StashDebug_populateList(self)
	local text = self.searchEntryBox and string.lower(string.trim(self.searchEntryBox:getInternalText())) or ""
	if text == "" then return end
	local list = self.datas
	local items = list.items
	list:clear()
	for _, listItem in ipairs(items) do
		if string.find(string.lower(listItem.text), text, 1, true) then list:addItem(listItem.text, listItem.item) end
	end
	list:setScrollHeight(#list.items * list.itemheight)
	list:setYScroll(0)
	self.selectedStash = nil
	self.viewBtn.enable = false
end
