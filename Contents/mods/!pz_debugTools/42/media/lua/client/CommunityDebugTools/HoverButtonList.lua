require "ISUI/ISScrollingListBox"

---@class HoverButtonList : ISScrollingListBox
local HoverButtonList = ISScrollingListBox:derive("HoverButtonList")

---@param text string
---@param onClick function called as onClick(buttonTarget, item.item, rowIndex)
---@param isVisible function|nil called as isVisible(buttonTarget, item.item)
function HoverButtonList:addRowButton(text, onClick, isVisible, tooltip)
	table.insert(self.rowButtons, {text = text, onClick = onClick, isVisible = isVisible, tooltip = tooltip})
end

function HoverButtonList:getRowButtonsRight()
	local x = self:getWidth() - 4
	if self:isVScrollBarVisible() then x = x - self.vscroll:getWidth() end
	return x
end

function HoverButtonList:layoutRowButtons(item)
	local layout = {}
	local x = self:getRowButtonsRight()
	for i = #self.rowButtons, 1, -1 do
		local button = self.rowButtons[i]
		if not button.isVisible or button.isVisible(self.buttonTarget, item.item) then
			local w = getTextManager():MeasureStringX(self.font, button.text) + 12
			x = x - w
			table.insert(layout, {button = button, x = x, w = w})
			x = x - 2
		end
	end
	return layout, x
end

function HoverButtonList:buttonAt(item, mouseX)
	for _,entry in ipairs(self:layoutRowButtons(item)) do
		if mouseX >= entry.x and mouseX < entry.x + entry.w then return entry.button end
	end
end

function HoverButtonList:isRowHovered(item)
	return self.mouseoverselected == item.index and self:isMouseOver() and not self:isMouseOverScrollBar()
end

function HoverButtonList:doDrawItem(y, item, alt)
	local h = item.height or self.itemheight
	if (y + self:getYScroll() + h < 0) or (y + self:getYScroll() >= self.height) then
		return y + h
	end

	local hovered = self:isRowHovered(item)
	if self.selected == item.index then
		self:drawSelection(0, y, self:getWidth(), h-1)
	elseif hovered then
		self:drawMouseOverHighlight(0, y, self:getWidth(), h-1)
	end
	self:drawRectBorder(0, y, self:getWidth(), h, 0.5, self.borderColor.r, self.borderColor.g, self.borderColor.b)

	local textY = y + (h - self.fontHgt) / 2
	local c = item.textColor or self.textColor
	self:drawText(item.text, 10, textY, c.r, c.g, c.b, c.a, self.font)

	local right = self:getRowButtonsRight()
	if hovered and #self.rowButtons > 0 then
		local layout, left = self:layoutRowButtons(item)
		local mouseX = self:getMouseX()
		for _,entry in ipairs(layout) do
			local over = mouseX >= entry.x and mouseX < entry.x + entry.w
			local a = over and 0.6 or 0.3
			self:drawRect(entry.x, y + 2, entry.w, h - 4, a, 0.25, 0.25, 0.25)
			self:drawRectBorder(entry.x, y + 2, entry.w, h - 4, 0.6, 0.7, 0.7, 0.7)
			self:drawText(entry.button.text, entry.x + 6, textY, 1, 1, 1, over and 1 or 0.85, self.font)
			if over and entry.button.tooltip then self.hoverTooltip = entry.button.tooltip end
		end
		right = left - 4
	end

	if item.subText then
		local w = getTextManager():MeasureStringX(self.font, item.subText)
		self:drawText(item.subText, right - w - 4, textY, 0.6, 0.6, 0.6, 0.8, self.font)
	end

	return y + h
end

function HoverButtonList:prerender()
	self.hoverTooltip = nil
	ISScrollingListBox.prerender(self)
end

function HoverButtonList:render()
	ISScrollingListBox.render(self)
	if self.hoverTooltip then
		local w = getTextManager():MeasureStringX(UIFont.Small, self.hoverTooltip) + 8
		local x = math.min(self:getMouseX() + 12, self:getWidth() - w)
		local y = self:getMouseY() + 16
		self:drawRect(x, y, w, self.fontHgt + 4, 0.9, 0, 0, 0)
		self:drawRectBorder(x, y, w, self.fontHgt + 4, 0.8, 0.6, 0.6, 0.6)
		self:drawText(self.hoverTooltip, x + 4, y + 2, 1, 1, 1, 1, UIFont.Small)
	end
end

function HoverButtonList:onMouseDown(x, y)
	local row = self:rowAt(x, y)
	local item = self.items[row]
	local button = item and self:buttonAt(item, x)
	if button then
		getSoundManager():playUISound("UIActivateButton")
		button.onClick(self.buttonTarget, item.item, row)
		return true
	end
	return ISScrollingListBox.onMouseDown(self, x, y)
end

function HoverButtonList:onMouseDoubleClick(x, y)
	local item = self.items[self:rowAt(x, y)]
	if item and self:buttonAt(item, x) then return true end
	return ISScrollingListBox.onMouseDoubleClick(self, x, y)
end

function HoverButtonList:new(x, y, width, height, buttonTarget)
	local o = ISScrollingListBox.new(self, x, y, width, height)
	o.rowButtons = {}
	o.buttonTarget = buttonTarget
	o.drawBorder = true
	return o
end

return HoverButtonList
