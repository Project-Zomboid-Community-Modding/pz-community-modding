require "DebugUIs/ISSpawnVehicleUI.lua"
local AUD = require "CommunityDebugTools/debugToolbar"
require "DebugUIs/DebugMenu/ISDebugMenu"

local ISDebugMenu_setupButtons = ISDebugMenu.setupButtons
function ISDebugMenu:setupButtons()
	ISDebugMenu_setupButtons(self)
	self:addButtonInfoAfter("Cheats", "Vehicle", function() DebugContextMenu.onSpawnVehicle(getPlayer()) end, "MAIN")
end


local update = ISSpawnVehicleUI.update
function ISSpawnVehicleUI:update()
	update(self)
	self.vehicle = self.vehicle or self.player:getVehicle()
	if self.vehicle then
		self.repair:setEnable(true)
		self.getKey:setEnable(true)
		if self.hotWireButton then
			self.hotWireButton:setEnable(true)
		end
	else
		self.repair:setEnable(false)
		self.getKey:setEnable(false)
		if self.hotWireButton then
			self.hotWireButton:setEnable(false)
		end
	end
end


--[[ add more buttons ]]
require "DebugUIs/ISSpawnVehicleUI"
local ceDebug = require "!!!communityPatchDebugTools - shared"
local Vehicles = ceDebug.Vehicles

local function removeAll() Vehicles.removeAll() end
local function reload(ui,button) Vehicles.reload(ui:getVehicle()) end

local function addButton(ui,x,y,w,h,text,target,fn)
	local button = ISButton:new(x,y,w,h,text,target,fn)
	button.borderColor = {r=1, g=1, b=1, a=0.1}
	button:initialise()
	ui:addChild(button)
	return button
end

local initialise = ISSpawnVehicleUI.initialise
ISSpawnVehicleUI.initialise = function(self)
	initialise(self)

	local height = self:getHeight()
	local x = 10
	local w, h = 80, 25
	local y = height-h-10

	self.zxReload = addButton(self, x, y, w, h, ("Reload"), self, reload)
	y = y-h-10
	self.zxRemoveAll = addButton(self, x, y, w, h, ("Remove All"), self, removeAll)
	y = y-h-10
	self.hotWireButton = addButton(self, x, y, w, h, ("Toggle Hotwire"), self, ISSpawnVehicleUI.onClick)
end


local onClick = ISSpawnVehicleUI.onClick
function ISSpawnVehicleUI:onClick(button)
	if self.player and self.vehicle then
		if button.internal == "TOGGLE_HOTWIRE" then
			---@type BaseVehicle
			local car = self.vehicle
			if car then
				sendClientCommand(self.player, "vehicle", "cheatHotwire", { vehicle = car:getId(), hotwired = (not car:isHotwired()), broken = false })
			end
		end
	end
	onClick(self, button)
end

ISSpawnVehicleUI.highlightColor = {r=0.2, g=1.0, b=0.2, a=1.0}
ISSpawnVehicleUI.highlightMargin = 0.15
ISSpawnVehicleUI.highlightThickness = 2

local highlightCorners = {}
local cornerSigns = { { -1, -1 }, { 1, -1 }, { 1, 1 }, { -1, 1 } }

function ISSpawnVehicleUI:highlightVehicle(vehicle)
	local script = vehicle:getScript()
	if not script then return end
	local extents, centerOfMass = script:getExtents(), script:getCenterOfMassOffset()
	local scale = 1 + ISSpawnVehicleUI.highlightMargin
	local halfX, halfZ = extents:x() / 2 * scale, extents:z() / 2 * scale
	local z = math.floor(vehicle:getZ())
	for i, sign in ipairs(cornerSigns) do
		highlightCorners[i] = highlightCorners[i] or Vector3f.new()
		vehicle:getWorldPos(centerOfMass:x() + sign[1] * halfX, 0, centerOfMass:z() + sign[2] * halfZ, highlightCorners[i])
	end
	local color = ISSpawnVehicleUI.highlightColor
	local playerNum = self.player:getPlayerNum()
	local left, top = getPlayerScreenLeft(playerNum), getPlayerScreenTop(playerNum)
	local renderer = getRenderer()
	for i = 1, 4 do
		local a, b = highlightCorners[i], highlightCorners[i % 4 + 1]
		local x1, y1 = left + isoToScreenX(playerNum, a:x(), a:y(), z), top + isoToScreenY(playerNum, a:x(), a:y(), z)
		local x2, y2 = left + isoToScreenX(playerNum, b:x(), b:y(), z), top + isoToScreenY(playerNum, b:x(), b:y(), z)
		renderer:renderlinef(nil, x1, y1, x2, y2, color.r, color.g, color.b, color.a, ISSpawnVehicleUI.highlightThickness)
	end
end

local render = ISSpawnVehicleUI.render
function ISSpawnVehicleUI:render()
	render(self)
	if self.vehicle then self:highlightVehicle(self.vehicle) end
end
