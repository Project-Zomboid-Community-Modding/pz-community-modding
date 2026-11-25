local Tiles = require "CommunityDebugTools/Commands/Tiles"

BrushToolActions = BrushToolActions or { dragPaint = false, maxHistory = 100, undoStack = {}, redoStack = {} }

function BrushToolActions.findObject(square, spriteName)
	if not square then return end
	local objects = square:getObjects()
	for i = objects:size() - 1, 0, -1 do
		local object = objects:get(i)
		local sprite = object:getSprite()
		if sprite and sprite:getName() == spriteName then return object end
	end
end

local function applyAdd(square, spriteName)
	if not square or not spriteName or BrushToolActions.findObject(square, spriteName) then return false end
	if isClient() then
		sendAddObjectToMap(square, spriteName)
	else
		ISBrushToolTileCursor.onTileObjectAdded(square, spriteName)
	end
	return true
end

local function applyRemove(square, spriteName)
	local object = BrushToolActions.findObject(square, spriteName)
	if not object then return false end
	Tiles.destroy(object)
	return true
end

local function push(stack, entry)
	table.insert(stack, entry)
	if #stack > BrushToolActions.maxHistory then table.remove(stack, 1) end
end

function BrushToolActions.onHistoryChanged()
	local manager = BrushToolManager and BrushToolManager.instance
	if manager and manager.updateHistoryButtons then manager:updateHistoryButtons() end
end

function BrushToolActions.record(kind, square, spriteName)
	if not square or not spriteName then return end
	push(BrushToolActions.undoStack, { kind = kind, x = square:getX(), y = square:getY(), z = square:getZ(), sprite = spriteName })
	BrushToolActions.redoStack = {}
	BrushToolActions.onHistoryChanged()
end

function BrushToolActions.add(square, spriteName)
	if applyAdd(square, spriteName) then BrushToolActions.record("add", square, spriteName) end
end

function BrushToolActions.remove(object)
	local square = object and object:getSquare()
	if not square then return end
	local sprite = object:getSprite()
	local spriteName = sprite and sprite:getName()
	Tiles.destroy(object)
	BrushToolActions.record("remove", square, spriteName)
end

local function apply(entry, reverse)
	local square = getCell():getGridSquare(entry.x, entry.y, entry.z)
	if not square then return end
	if (entry.kind == "add") ~= reverse then return applyAdd(square, entry.sprite) end
	return applyRemove(square, entry.sprite)
end

function BrushToolActions.undo()
	local entry = table.remove(BrushToolActions.undoStack)
	if not entry then return end
	apply(entry, true)
	push(BrushToolActions.redoStack, entry)
	BrushToolActions.onHistoryChanged()
end

function BrushToolActions.redo()
	local entry = table.remove(BrushToolActions.redoStack)
	if not entry then return end
	apply(entry, false)
	push(BrushToolActions.undoStack, entry)
	BrushToolActions.onHistoryChanged()
end

local function isMouseOverUI()
	local uis = UIManager.getUI()
	for i = 0, uis:size() - 1 do
		if uis:get(i):isMouseOver() then return true end
	end
	return false
end

function BrushToolActions.getMouseSquare(z)
	local x, y = ISCoordConversion.ToWorld(getMouseXScaled(), getMouseYScaled(), z)
	return getCell():getGridSquare(math.floor(x), math.floor(y), z)
end

function BrushToolActions.paint(cursor, z, action)
	if not BrushToolActions.dragPaint then
		cursor.paintStroke = nil
		cursor.paintedStroke = false
		return
	end
	local playerObj = getSpecificPlayer(cursor.player)
	if not playerObj or not playerObj:isBuildButtonDown() then
		cursor.paintStroke = nil
		return
	end
	if not cursor.paintStroke then
		cursor.paintStroke = {}
		cursor.paintedStroke = false
		cursor.paintBlocked = isMouseOverUI()
	end
	if cursor.paintBlocked then return end
	local square = BrushToolActions.getMouseSquare(z)
	if not square then return end
	local key = square:getX() .. "," .. square:getY()
	if not cursor.paintStroke[key] then
		cursor.paintStroke[key] = true
		cursor.paintedStroke = true
		action(cursor, square)
	end
	return square
end

function BrushToolActions.consumePaintedStroke(cursor)
	if not cursor.paintedStroke then return false end
	cursor.paintedStroke = false
	return true
end
