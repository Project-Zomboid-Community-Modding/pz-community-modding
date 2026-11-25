if not BrushToolManager then return end

local function getDrag(playerNum)
	return getCell() and getCell():getDrag(playerNum)
end

local function getDestroyBrush(playerNum)
	local drag = getDrag(playerNum)
	if drag and drag.isDestroyBrush then return drag end
end

function BrushToolManager:addToolButton(x, y, width, title, internal)
	local button = ISButton:new(x, y, width, self.help:getHeight(), title, self, BrushToolManager.onClick)
	button.internal = internal
	button:initialise()
	button:instantiate()
	self:addChild(button)
	return button
end

local BrushToolManager_createChildren = BrushToolManager.createChildren
function BrushToolManager:createChildren()
	BrushToolManager_createChildren(self)
	local x, width = self.help:getX(), self.help:getWidth()
	local halfWidth = (width - 10) / 2

	self.eyedropper = self:addToolButton(x, self.help:getBottom() + 10, width, "Eyedropper", "EYEDROPPER")
	self.undo = self:addToolButton(x, self.eyedropper:getBottom() + 10, halfWidth, "Undo", "UNDO")
	self.redo = self:addToolButton(self.undo:getRight() + 10, self.undo:getY(), halfWidth, "Redo", "REDO")

	self.brushOptions = ISTickBox:new(x, self.undo:getBottom() + 10, width, 20, "", self, BrushToolManager.onBrushOptionTicked)
	self.brushOptions:initialise()
	self.brushOptions:instantiate()
	self.brushOptions:addOption("Destroy brush")
	self.brushOptions:addOption("Include floors")
	self.brushOptions:addOption("Drag to paint")
	self:addChild(self.brushOptions)
	self.brushOptions:setSelected(1, getDestroyBrush(self.character:getPlayerNum()) ~= nil)
	self.brushOptions:setSelected(2, DestroyBrushCursor and DestroyBrushCursor.includeFloors or false)
	self.brushOptions:setSelected(3, BrushToolActions.dragPaint)

	self:updateHistoryButtons()
	self:shrinkWrap(10, 10, nil)
end

function BrushToolManager:updateHistoryButtons()
	if not self.undo then return end
	local undoCount, redoCount = #BrushToolActions.undoStack, #BrushToolActions.redoStack
	self.undo:setTooltip(undoCount .. " to undo")
	self.redo:setTooltip(redoCount .. " to redo")
	self.undo:setEnable(undoCount > 0)
	self.redo:setEnable(redoCount > 0)
end

function BrushToolManager:onBrushOptionTicked(index, selected)
	local playerNum = self.character:getPlayerNum()
	if index == 1 then
		if selected then
			getCell():setDrag(DestroyBrushCursor:new(self.character), playerNum)
			self.brushOptions:setSelected(1, true)
		elseif getDestroyBrush(playerNum) then
			getCell():setDrag(nil, playerNum)
		end
	elseif index == 2 then
		DestroyBrushCursor.includeFloors = selected
	elseif index == 3 then
		BrushToolActions.dragPaint = selected
	end
end

local BrushToolManager_onClick = BrushToolManager.onClick
function BrushToolManager:onClick(button)
	if button.internal == "EYEDROPPER" then
		getCell():setDrag(EyedropperCursor:new(self.character), self.character:getPlayerNum())
		return
	elseif button.internal == "UNDO" then
		return BrushToolActions.undo()
	elseif button.internal == "REDO" then
		return BrushToolActions.redo()
	elseif button.internal ~= "HELP" then
		return BrushToolManager_onClick(self, button)
	end
	local w, h = 380, 340
	local text = "Controls:\n" ..
				"RMC -> Copy/Destroy tile\n" ..
				"When tile chosen -> keys '[' ']' to move between tiles\n" ..
				"Tile search -> filter by sheet, sprite or tile name\n" ..
				"Eyedropper -> LMC picks a tile into the tile brush\n" ..
				"Destroy brush -> LMC removes the top object on a square\n" ..
				"Rotate key (R) -> cycles the targeted object on a square\n" ..
				"Drag to paint -> hold LMC to brush across squares\n" ..
				"Undo / Redo -> placed and destroyed tiles (not their contents)"
	local modal = ISModalDialog:new(getCore():getScreenWidth()/2 - w/2, getCore():getScreenHeight() / 2 - h/2, w, h, text, false)
	modal:initialise()
	modal:addToUIManager()
end

local BrushToolManager_close = BrushToolManager.close
function BrushToolManager:close()
	local playerNum = self.character:getPlayerNum()
	local drag = getDrag(playerNum)
	if drag and (drag.isDestroyBrush or drag.isEyedropper) then getCell():setDrag(nil, playerNum) end
	BrushToolManager_close(self)
end
