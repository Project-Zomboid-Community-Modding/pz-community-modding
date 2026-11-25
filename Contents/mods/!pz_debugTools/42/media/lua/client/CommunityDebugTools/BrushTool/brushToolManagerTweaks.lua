if not BrushToolManager then return end

local function getDestroyBrush(playerNum)
	local drag = getCell() and getCell():getDrag(playerNum)
	if drag and drag.isDestroyBrush then return drag end
end

local BrushToolManager_createChildren = BrushToolManager.createChildren
function BrushToolManager:createChildren()
	BrushToolManager_createChildren(self)
	self.brushOptions = ISTickBox:new(self.help:getX(), self.help:getBottom() + 10, self.help:getWidth(), 20, "", self, BrushToolManager.onBrushOptionTicked)
	self.brushOptions:initialise()
	self.brushOptions:instantiate()
	self.brushOptions:addOption("Destroy brush")
	self.brushOptions:addOption("Include floors")
	self:addChild(self.brushOptions)
	self.brushOptions:setSelected(1, getDestroyBrush(self.character:getPlayerNum()) ~= nil)
	self.brushOptions:setSelected(2, DestroyBrushCursor and DestroyBrushCursor.includeFloors or false)
	self:shrinkWrap(10, 10, nil)
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
	end
end

local BrushToolManager_onClick = BrushToolManager.onClick
function BrushToolManager:onClick(button)
	if button.internal ~= "HELP" then return BrushToolManager_onClick(self, button) end
	local w, h = 340, 300
	local text = "Controls:\n" ..
				"RMC -> Copy/Destroy tile\n" ..
				"When tile chosen -> keys '[' ']' to move between tiles\n" ..
				"Tile search -> filter by sheet, sprite or tile name\n" ..
				"Destroy brush -> LMC removes the top object on a square\n" ..
				"Destroy brush -> Rotate key (R) cycles through the objects on a square"
	local modal = ISModalDialog:new(getCore():getScreenWidth()/2 - w/2, getCore():getScreenHeight() / 2 - h/2, w, h, text, false)
	modal:initialise()
	modal:addToUIManager()
end

local BrushToolManager_close = BrushToolManager.close
function BrushToolManager:close()
	local playerNum = self.character:getPlayerNum()
	if getDestroyBrush(playerNum) then getCell():setDrag(nil, playerNum) end
	BrushToolManager_close(self)
end
