DestroyBrushCursor = ISBuildingObject:derive("DestroyBrushCursor")
DestroyBrushCursor.includeFloors = false
DestroyBrushCursor.outlineColor = {r=1.0, g=0.2, b=0.2, a=0.5}

function DestroyBrushCursor:isFloorTarget()
	return DestroyBrushCursor.includeFloors
end

function DestroyBrushCursor:getTargets(square)
	local targets = {}
	if not square then return targets end
	local includeFloors = self:isFloorTarget()
	local objects = square:getObjects()
	for i = objects:size() - 1, 0, -1 do
		local object = objects:get(i)
		if object:getSprite() and object:getSprite():getName() and not instanceof(object, "IsoWorldInventoryObject") and (includeFloors or not object:isFloor()) then
			table.insert(targets, object)
		end
	end
	return targets
end

function DestroyBrushCursor:getTarget(square)
	local targets = self:getTargets(square)
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

function DestroyBrushCursor:useTarget(target)
	BrushToolActions.remove(target)
end

function DestroyBrushCursor:paintSquare(square)
	local target = self:getTarget(square)
	if target then self:useTarget(target) end
end

function DestroyBrushCursor:tryBuild(x, y, z)
	if BrushToolActions.consumePaintedStroke(self) then return end
	ISBuildingObject.tryBuild(self, x, y, z)
end

function DestroyBrushCursor:create(x, y, z)
	local target = self:getTarget(getCell():getGridSquare(x, y, z))
	if target then self:useTarget(target) end
end

function DestroyBrushCursor:renderTarget(target, x, y, z)
	self.RENDER_SPRITE = self.RENDER_SPRITE or IsoSprite.new()
	local spriteName = target:getSprite():getName()
	if self.RENDER_SPRITE_NAME ~= spriteName then
		self.RENDER_SPRITE:LoadSingleTexture(spriteName)
		self.RENDER_SPRITE_NAME = spriteName
	end
	self.RENDER_SPRITE:RenderGhostTileRed(x, y, z)
end

function DestroyBrushCursor:render(x, y, z, square)
	local painted = self.allowPaint and BrushToolActions.paint(self, z, self.paintSquare)
	if painted then
		square = painted
		x, y = painted:getX(), painted:getY()
	end
	local color = self.outlineColor
	renderIsoRect(x + 1, y + 1, z, 1, color.r, color.g, color.b, color.a, 1)
	local target = self:getTarget(square)
	if target then self:renderTarget(target, x, y, z) end
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
	o.allowPaint = true
	o.noNeedHammer = true
	o.skipBuildAction = true
	o.skipWalk2 = true
	o.targetCycle = 0
	return o
end

return DestroyBrushCursor
