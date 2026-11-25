local DestroyBrushCursor = require "CommunityDebugTools/BrushTool/DestroyBrushCursor"

EyedropperCursor = DestroyBrushCursor:derive("EyedropperCursor")
EyedropperCursor.outlineColor = {r=0.3, g=0.8, b=1.0, a=0.5}

function EyedropperCursor:isFloorTarget()
	return true
end

function EyedropperCursor:useTarget(target)
	local spriteName = target:getSprite():getName()
	getCell():setDrag(ISBrushToolTileCursor:new(spriteName, spriteName, self.character), self.player)
end

function EyedropperCursor:renderTarget(target, x, y, z)
	self.RENDER_SPRITE = self.RENDER_SPRITE or IsoSprite.new()
	local spriteName = target:getSprite():getName()
	if self.RENDER_SPRITE_NAME ~= spriteName then
		self.RENDER_SPRITE:LoadSingleTexture(spriteName)
		self.RENDER_SPRITE_NAME = spriteName
	end
	self.RENDER_SPRITE:RenderGhostTile(x, y, z)
end

function EyedropperCursor:deactivate()
end

function EyedropperCursor:new(character)
	local o = DestroyBrushCursor.new(self, character)
	o.isDestroyBrush = false
	o.isEyedropper = true
	o.allowPaint = false
	return o
end

return EyedropperCursor
