require "DebugUIs/ISSpawnVehicleUI.lua"
require "InitToolBar"
require "DebugUIs/DebugMenu/ISDebugMenu"

local ISDebugMenu_setupButtons = ISDebugMenu.setupButtons
function ISDebugMenu:setupButtons()
    ISDebugMenu_setupButtons(self)
    self:addButtonInfoAfter("Cheats", "Vehicle", function() DebugContextMenu.onSpawnVehicle(getPlayer()) end, "MAIN")
end


--Make is so the vehicle you are in counts as the ISSpawnVehicleUI.vehicle
local update = ISSpawnVehicleUI.update
function ISSpawnVehicleUI:update()

    --Added toggle hotWire to the panel
    ---embedding it into initialise of ISSpawnVehicleUI cause issues with layout
    if not self.hotWire then
        self.hotWire = ISButton:new(10, self.getKey:getY()-35, 80, 25, "Toggle Hotwire", self, ISSpawnVehicleUI.onClick)
        self.hotWire.anchorTop = false
        self.hotWire.anchorBottom = true
        self.hotWire.internal = "TOGGLE_HOTWIRE"
        self.hotWire:initialise()
        self.hotWire:instantiate()
        self.hotWire.borderColor = {r=1, g=1, b=1, a=0.1}
        self:addChild(self.hotWire)
    end

    update(self)
    self.vehicle = self.vehicle or self.player:getVehicle()
    if self.vehicle then
        self.repair:setEnable(true)
        self.getKey:setEnable(true)
        self.hotWire:setEnable(true)
    else
        self.repair:setEnable(false)
        self.getKey:setEnable(false)
        self.hotWire:setEnable(false)
    end
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