if not ISBrushToolTileCursor then return end

function ISBrushToolTileCursor:paintSquare(square)
	BrushToolActions.add(square, self:getSprite())
end

local ISBrushToolTileCursor_render = ISBrushToolTileCursor.render
function ISBrushToolTileCursor:render(x, y, z, square)
	ISBrushToolTileCursor_render(self, x, y, z, square)
	if BrushToolActions then BrushToolActions.paint(self, z, self.paintSquare) end
end

local ISBrushToolTileCursor_tryBuild = ISBrushToolTileCursor.tryBuild
function ISBrushToolTileCursor:tryBuild(x, y, z)
	if not BrushToolActions then return ISBrushToolTileCursor_tryBuild(self, x, y, z) end
	if BrushToolActions.consumePaintedStroke(self) then return end
	local square = getCell():getGridSquare(x, y, z)
	local spriteName = self:getSprite()
	local existed = BrushToolActions.findObject(square, spriteName)
	ISBrushToolTileCursor_tryBuild(self, x, y, z)
	if not existed then BrushToolActions.record("add", square, spriteName) end
end
