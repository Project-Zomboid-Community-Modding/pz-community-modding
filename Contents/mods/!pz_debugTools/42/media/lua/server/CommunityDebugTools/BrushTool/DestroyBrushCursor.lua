local Tiles = require "CommunityDebugTools/Commands/Tiles"

DestroyBrushCursor = ISBuildingObject:derive("DestroyBrushCursor")
DestroyBrushCursor.includeFloors = false
DestroyBrushCursor.outlineColor = {r=1.0, g=0.2, b=0.2, a=0.5}

function DestroyBrushCursor.getTargets(square)
	local targets = {}
	if not square then return targets end
	local objects = square:getObjects()
	for i = objects:size() - 1, 0, -1 do
		local object = objects:get(i)
		if object:getSprite() and not instanceof(object, "IsoWorldInventoryObject") and (DestroyBrushCursor.includeFloors or not object:isFloor()) then
			table.insert(targets, object)
		end
	end
	return targets
end

function DestroyBrushCursor:getTarget(square)
	local targets = DestroyBrushCursor.getTargets(square)
	if square ~= self.targetSquare then
		self.targetSquare = square
		self.targetCycle = 0
	end
	if #targets == 0 then return end
	return targets[(self.targetCycle % #targets) + 1]
end

function DestroyBrushCursor:rotateKey(key)
	if getCore():isKey(KeybindId.ROTATE_BUILDING, key) then
		self.targetCycle = (self.targetCycle or 0) + 1
	end
end

function DestroyBrushCursor:isValid(square)
	return self:getTarget(square) ~= nil
end

function DestroyBrushCursor:create(x, y, z)
	Tiles.destroy(self:getTarget(getCell():getGridSquare(x, y, z)))
end

function DestroyBrushCursor:render(x, y, z, square)
	local color = DestroyBrushCursor.outlineColor
	renderIsoRect(x + 1, y + 1, z, 1, color.r, color.g, color.b, color.a, 1)
	local target = self:getTarget(square)
	if not target then return end
	local spriteName = target:getSprite():getName()
	if not spriteName then return end
	self.RENDER_SPRITE = self.RENDER_SPRITE or IsoSprite.new()
	if self.RENDER_SPRITE_NAME ~= spriteName then
		self.RENDER_SPRITE:LoadSingleTexture(spriteName)
		self.RENDER_SPRITE_NAME = spriteName
	end
	self.RENDER_SPRITE:RenderGhostTileRed(x, y, z)
end

function DestroyBrushCursor:deactivate()
	local manager = BrushToolManager and BrushToolManager.instance
	if manager and manager.brushOptions then manager.brushOptions:setSelected(1, false) end
end

function DestroyBrushCursor:new(character)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o:init()
	o.character = character
	o.player = character:getPlayerNum()
	o.isDestroyBrush = true
	o.targetCycle = 0
	o.noNeedHammer = true
	o.skipBuildAction = true
	o.skipWalk2 = true
	return o
end
