AUD = {}
AUD.Config = {}


AUD.Config.Buttons = {}
AUD.Config.Buttons.RED = {r=0.5, g=0.0, b=0.0, a=0.9}
AUD.Config.Buttons.GREEN = {r=0.0, g=0.5, b=0.0, a=0.9}

AUD.Config.Buttons.Width = 150
AUD.Config.Buttons.Height = 20
AUD.Config.Buttons.LeftIndent = 20
AUD.Config.Buttons.TopIndent = 10
AUD.Config.Buttons.VerticalInterval = 10
AUD.Config.Buttons.HorizontalInterval = 10
AUD.Config.Buttons.VerticalStep = AUD.Config.Buttons.Height + AUD.Config.Buttons.VerticalInterval


AUD.Config.isSelectVehicle = false
AUD.Config.selectedVehicle = nil
AUD.Config.isSpawnVehicle = false
AUD.Config.spawnVehicleScript = nil


function AUD.setNewButton(buttonType, audModule, onClick)
    local xMax = ISEquippedItem.instance.x-8
    local yMax = ISEquippedItem.instance:getBottom()+5

    ---@type Texture
    local texture = audModule.texture_Off
    
    audModule.toolbarButton = buttonType:new(xMax, yMax, texture:getHeight(), texture:getWidth(), "", nil, onClick)
    audModule.toolbarButton:setImage(audModule.texture_Off)
    audModule.toolbarButton:setDisplayBackground(false)
    audModule.toolbarButton.borderColor = {r=1, g=1, b=1, a=0.1}

    ISEquippedItem.instance:addChild(audModule.toolbarButton)
    ISEquippedItem.instance:setHeight(ISEquippedItem.instance:getHeight()+audModule.toolbarButton:getHeight()+5)
end


local function createButtons()

    AUD.DebugPanel.debugPanelWindowButton()
    AUD.InspectorPanel.inspectorButton()
    AUD.LuaExplorerPanel.explorerButton()
    AUD.TeleportPanel.teleportButton()
    
    AUD.RestoreLayout.restoreWindows()
end


Events.OnCreatePlayer.Add(createButtons)





