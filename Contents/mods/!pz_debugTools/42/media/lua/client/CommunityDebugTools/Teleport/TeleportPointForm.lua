local AUD = require "CommunityDebugTools/debugToolbar"

AddPointPanel = ISPanel:derive("AddPointPanel")

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)

function AddPointPanel.open(point, defaults)
	if AddPointPanel.instance then AddPointPanel.instance:close() end
	local w, h = 300, 260
	local modal = AddPointPanel:new(getCore():getScreenWidth()/2 - w/2, getCore():getScreenHeight()/2 - h/2, w, h, point, defaults)
	modal:initialise()
	modal:addToUIManager()
	modal.textEntryName:focus()
	AddPointPanel.instance = modal
	return modal
end

function AddPointPanel:initialise()
	ISPanel.initialise(self)
	self:create()
end

function AddPointPanel:render()
	ISPanel.render(self)
	local title = self.point and "Edit point" or "Add point"
	self:drawTextCentre(title, self.width/2, 10, 1,1,1,1, UIFont.Medium)
	for _,field in ipairs(self.fields) do
		self:drawTextRight(field.label, self.labelRight, field.entry:getY() + (field.entry:getHeight() - FONT_HGT_SMALL)/2, 1,1,1,1, UIFont.Small)
	end
	if self.errorText then
		self:drawTextCentre(self.errorText, self.width/2, self.save:getY() - FONT_HGT_SMALL - 6, 1,0.3,0.3,1, UIFont.Small)
	end
end

function AddPointPanel:addField(label, value, y)
	local entryHgt = FONT_HGT_SMALL + 6
	local entry = ISTextEntryBox:new(tostring(value or ""), self.labelRight + 8, y, self.width - self.labelRight - 20, entryHgt)
	entry:initialise()
	entry:instantiate()
	entry:setClearButton(true)
	entry.onCommandEntered = function() self:onSave() end
	self:addChild(entry)
	table.insert(self.fields, {label = label, entry = entry})
	return entry, y + entryHgt + 6
end

function AddPointPanel:create()
	local btnHgt = FONT_HGT_SMALL + 6
	local values = self.point or self.defaults or {}
	self.fields = {}
	self.labelRight = 75

	local y = 20 + FONT_HGT_MEDIUM
	self.textEntryName, y = self:addField("Name:", values.name, y)
	self.textEntryX, y = self:addField("X:", values.x, y)
	self.textEntryY, y = self:addField("Y:", values.y, y)
	self.textEntryZ, y = self:addField("Z:", values.z, y)
	self.textEntryCategory, y = self:addField("Category:", values.category, y)

	self.select = ISButton:new(self.labelRight + 8, y, self.width - self.labelRight - 20, btnHgt, "Use My Position", self, AddPointPanel.onOptionMouseDown)
	self.select.internal = "SELECT"
	self.select:initialise()
	self.select:instantiate()
	self.select.borderColor = {r=1, g=1, b=1, a=0.1}
	self:addChild(self.select)

	y = y + btnHgt + FONT_HGT_SMALL + 16
	local btnWid = 100
	self.save = ISButton:new((self:getWidth() / 2) - btnWid - 5, y, btnWid, btnHgt, self.point and "Save" or "Add", self, AddPointPanel.onOptionMouseDown)
	self.save.internal = "SAVE"
	self.save:initialise()
	self.save:instantiate()
	self.save.borderColor = {r=1, g=1, b=1, a=0.1}
	self:addChild(self.save)

	self.cancel = ISButton:new((self:getWidth() / 2) + 5, y, btnWid, btnHgt, getText("UI_Cancel"), self, AddPointPanel.onOptionMouseDown)
	self.cancel.internal = "CANCEL"
	self.cancel:initialise()
	self.cancel:instantiate()
	self.cancel.borderColor = {r=1, g=1, b=1, a=0.1}
	self:addChild(self.cancel)

	self:setHeight(self.cancel:getBottom() + 12)
end

function AddPointPanel:onSave()
	local values = {
		name = string.trim(self.textEntryName:getText()),
		x = tonumber(self.textEntryX:getText()),
		y = tonumber(self.textEntryY:getText()),
		z = tonumber(self.textEntryZ:getText()),
		category = string.trim(self.textEntryCategory:getText()),
	}
	if values.name == "" then self.errorText = "Name is required" return end
	if not (values.x and values.y and values.z) then self.errorText = "X, Y and Z must be numbers" return end

	if self.point then
		AUDTeleport.updatePoint(self.point, values)
	else
		AUDTeleport.addPoint(values)
	end
	self:close()
end

function AddPointPanel:onOptionMouseDown(button, x, y)
	if button.internal == "SAVE" then
		self:onSave()
	elseif button.internal == "SELECT" then
		local player = getSpecificPlayer(0)
		if not player then return end
		local point = AUDTeleport.makePointAt(player)
		self.textEntryX:setText(tostring(point.x))
		self.textEntryY:setText(tostring(point.y))
		self.textEntryZ:setText(tostring(point.z))
	elseif button.internal == "CANCEL" then
		self:close()
	end
end

function AddPointPanel:close()
	self:setVisible(false)
	self:removeFromUIManager()
	if AddPointPanel.instance == self then AddPointPanel.instance = nil end
end

function AddPointPanel:new(x, y, width, height, point, defaults)
	local o = ISPanel:new(x, y, width, height)
	setmetatable(o, self)
	self.__index = self
	o.variableColor={r=0.9, g=0.55, b=0.1, a=1}
	o.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
	o.backgroundColor = {r=0, g=0, b=0, a=0.8}
	o.point = point
	o.defaults = defaults
	o.moveWithMouse = true
	return o
end
