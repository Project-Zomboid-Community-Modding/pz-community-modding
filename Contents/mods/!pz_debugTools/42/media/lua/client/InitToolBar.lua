local AUD = {}
AUD.Config = {}


AUD.Config.Buttons = {}
AUD.Config.Buttons.RED = {r=0.5, g=0.0, b=0.0, a=0.9}
AUD.Config.Buttons.GREEN = {r=0.0, g=0.5, b=0.0, a=0.9}

AUD.Config.Buttons.RED_HIGHLIGHT = {r=0.75, g=0.0, b=0.0, a=0.9}
AUD.Config.Buttons.GREEN_HIGHLIGHT = {r=0.0, g=0.75, b=0.0, a=0.9}

AUD.Config.Buttons.Width = 150
AUD.Config.Buttons.Height = 20
AUD.Config.Buttons.LeftIndent = 10
AUD.Config.Buttons.TopIndent = 10
AUD.Config.Buttons.VerticalInterval = 5
AUD.Config.Buttons.HorizontalInterval = 10
AUD.Config.Buttons.VerticalStep = AUD.Config.Buttons.Height + AUD.Config.Buttons.VerticalInterval


AUD.Config.isSelectVehicle = false
AUD.Config.selectedVehicle = nil
AUD.Config.isSpawnVehicle = false
AUD.Config.spawnVehicleScript = nil


require "DebugUIs/DebugMenu/ISDebugMenu"
function AUD.getDebugMenuAdjacentPos()

    local x = ISDebugMenu and ISDebugMenu.instance and ISDebugMenu.instance:getX()+ISDebugMenu.instance:getWidth() or 300
    local y = ISDebugMenu and ISDebugMenu.instance and ISDebugMenu.instance:getY() or 100

    return x+5, y
end


function ISDebugMenu:addButtonInfoAfter(_after, _title, _func, _tab, _marginTop)
    self.buttons = self.buttons or {};
    local indexFound = #self.buttons
    for index,buttonData in pairs(self.buttons) do if buttonData.title == _after then indexFound = index end end
    table.insert(self.buttons, indexFound+1, { title = _title, func = _func, tab = _tab, marginTop = (_marginTop or 0) })
end





function AUD.setNewButton(buttonType, audModule, onClick)
    local xMax = ISEquippedItem.instance.x-5
    local yMax = ISEquippedItem.instance:getBottom()+5
    ---@type Texture
    local texture = audModule.texture_Off
    local textureW, textureH = texture:getWidth(), texture:getHeight()
    audModule.toolbarButton = buttonType:new(xMax, yMax, textureW, textureH, "", nil, onClick)
    audModule.toolbarButton:forceImageSize(textureW, textureH)
    audModule.toolbarButton:setImage(texture)
    audModule.toolbarButton:setDisplayBackground(false)
    audModule.toolbarButton.borderColor = {r=1, g=1, b=1, a=0.1}

    ISEquippedItem.instance:addChild(audModule.toolbarButton)
    ISEquippedItem.instance:setHeight(ISEquippedItem.instance:getHeight()+audModule.toolbarButton:getHeight()+5)
end


local function createButtons()
    if not getDebug() then return end
    AUD.LuaExplorerPanel.explorerButton()
    AUD.TeleportPanel.teleportButton()
end


Events.OnCreatePlayer.Add(createButtons)

return AUD