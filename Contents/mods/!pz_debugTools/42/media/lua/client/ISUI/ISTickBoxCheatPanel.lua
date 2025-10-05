---@class ISTickBoxCheatPanel : ISTickBox
local ISTickBoxCheatPanel = ISTickBox:derive("ISTickBoxCheatPanel")

---CACHE VALUES
local UI_BORDER_SPACING = 10
local goodHighlightedColor = getCore():getGoodHighlitedColor()
local good_r, good_g, good_b = goodHighlightedColor:getR(), goodHighlightedColor:getG(), goodHighlightedColor:getB()
local badHighlightedColor = getCore():getBadHighlitedColor()
local bad_r, bad_g, bad_b = badHighlightedColor:getR(), badHighlightedColor:getG(), badHighlightedColor:getB()
local colors = {
    enabled = { r = good_r, g = good_g, b = good_b, a = 0.25 },
    disabled = { r = bad_r, g = bad_g, b = bad_b, a = 0.25 },
    hoverEnabled = { r = good_r, g = good_g, b = good_b, a = 0.5 },
    hoverDisabled = { r = bad_r, g = bad_g, b = bad_b, a = 0.5 },
}

---Override to make width fit parent ISCheatPanelUI
function ISTickBoxCheatPanel:setWidthToFit()
    local iSCheatPanelUI = self.parent --[[@as ISCheatPanelUI]]
	self.width = iSCheatPanelUI.width - (UI_BORDER_SPACING+1)*2 -- we completely override the width calculation with our own here
    ---@TODO: adapt width based on maximum size of options like the original function
end

---Override to center options and change colors and placements
function ISTickBoxCheatPanel:render()
    -- get the option box sizes
    local iSCheatPanelUI = self.parent --[[@as ISCheatPanelUI]]
    local h = self.boxSize -- was the previous option height
    local w = self.width -- use the tick box full width

    -- mostly kept from the original function
	local y = 0
	local c = 1
	local totalHgt = #self.options * (self.itemHgt + UI_BORDER_SPACING) - UI_BORDER_SPACING
	y = y + (self.height - totalHgt) / 2
	local textDY = (self.itemHgt - self.fontHgt) / 2
	local boxDY = 0
	self._textColor = self._textColor or { r = 1, g = 1, b = 1, a = 1 }

    -- iterate through options and draw the options
    for i,v in ipairs(self.options) do
        -- get the option state
        local disabled = not self:isSelected(i)
        local hover = self:isMouseOver() and (self.mouseOverOption == c)

        -- select the box color based on the option state
        local boxColor
        if hover then
            boxColor = disabled and colors.hoverDisabled or colors.hoverEnabled
        else
            boxColor = disabled and colors.disabled or colors.enabled
        end

        -- draw the option box
        self:drawRect(self.leftMargin, y+boxDY, w, h, boxColor.a, boxColor.r, boxColor.g, boxColor.b)
        self:drawRectBorder(self.leftMargin, y+boxDY, w, h, boxColor.a, boxColor.r, boxColor.g, boxColor.b)

        -- render the option text
		local textColor = self._textColor
		self:getTextColor(i, textColor)

        -- used to calculate the centered position
        local txtWidth = getTextManager():MeasureStringX(self.font, v)
        local txtX = self.width/2 - txtWidth/2

        -- draw text
        self:drawText(v, txtX, y+textDY, textColor.r, textColor.g, textColor.b, textColor.a, self.font)

        y = y + self.itemHgt + UI_BORDER_SPACING
		c = c + 1
    end

    -- this handles the tooltip, kept from the original function, nothing changed here
    if self:isMouseOver() and self.mouseOverOption and self.mouseOverOption ~= 0 and self.tooltip then
        local text = self.tooltip
        if not self.tooltipUI then
            self.tooltipUI = ISToolTip:new()
            self.tooltipUI:setOwner(self)
            self.tooltipUI:setVisible(false)
            self.tooltipUI:setAlwaysOnTop(true)
        end
        if not self.tooltipUI:getIsVisible() then
            if string.contains(self.tooltip, "\n") then
                self.tooltipUI.maxLineWidth = 1000 -- don't wrap the lines
            else
                self.tooltipUI.maxLineWidth = 300
            end
            self.tooltipUI:addToUIManager()
            self.tooltipUI:setVisible(true)
        end
        self.tooltipUI.description = text
        self.tooltipUI:setX(self:getMouseX() + 23)
        self.tooltipUI:setY(self:getMouseY() + 23)
    else
        if self.tooltipUI and self.tooltipUI:getIsVisible() then
            self.tooltipUI:setVisible(false)
            self.tooltipUI:removeFromUIManager()
        end
    end
end

return ISTickBoxCheatPanel