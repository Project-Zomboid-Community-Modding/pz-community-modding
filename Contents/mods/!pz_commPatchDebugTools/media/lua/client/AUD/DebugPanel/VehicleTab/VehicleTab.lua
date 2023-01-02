require("AUD/Init")
AUD.VehicleTab = {}

AUDVehicleTab = ISPanelJoypad:derive("AUDVehicleTab")

function AUDVehicleTab:initialise()
    ISPanelJoypad.initialise(self);

    self:instantiate()
    self:setAnchorRight(true)
    self:setAnchorLeft(true)
    self:setAnchorTop(true)
    self:setAnchorBottom(true)
    self:noBackground()
    self:setScrollChildren(true)
    self:addScrollBars()

    self.borderColor = {r=0, g=0, b=0, a=0};

    AUD.VehicleTab.addRepairVehicle(self, AUD.Config.Buttons.LeftIndent, AUD.Config.Buttons.TopIndent, AUD.Config.Buttons.Width, AUD.Config.Buttons.Height)
    AUD.VehicleTab.addGetVehicleKey(self, AUD.Config.Buttons.LeftIndent, AUD.Config.Buttons.TopIndent + AUD.Config.Buttons.VerticalStep, AUD.Config.Buttons.Width, AUD.Config.Buttons.Height)
    AUD.VehicleTab.addToggleHotwire(self, AUD.Config.Buttons.LeftIndent, AUD.Config.Buttons.TopIndent + AUD.Config.Buttons.VerticalStep*2, AUD.Config.Buttons.Width, AUD.Config.Buttons.Height)
    AUD.VehicleTab.addSelectVehicle(self, AUD.Config.Buttons.LeftIndent, AUD.Config.Buttons.TopIndent + AUD.Config.Buttons.VerticalStep*3, AUD.Config.Buttons.Width, AUD.Config.Buttons.Height)
    AUD.VehicleTab.addSelectThisVehicle(self, AUD.Config.Buttons.LeftIndent, AUD.Config.Buttons.TopIndent + AUD.Config.Buttons.VerticalStep*4, AUD.Config.Buttons.Width, AUD.Config.Buttons.Height)
    AUD.VehicleTab.addSpawnVehicle(self, AUD.Config.Buttons.LeftIndent, AUD.Config.Buttons.TopIndent + AUD.Config.Buttons.VerticalStep*5, AUD.Config.Buttons.Width, AUD.Config.Buttons.Height)
end


--- BUTTONS


function AUD.VehicleTab.addRepairVehicle(UIElement, x, y, width, height)
    local func = function(target, self)
        if AUD.Config.selectedVehicle then
            AUD.Config.selectedVehicle:repair()
        else
            getPlayer():Say("Vehicle not selected")
        end
    end

    local btn = ISButton:new(x, y, width, height, "Repair vehicle", nil, func)
    UIElement:addChild(btn);
end

function AUD.VehicleTab.addGetVehicleKey(UIElement, x, y, width, height)
    local func = function(target, self)
        if AUD.Config.selectedVehicle then
            getPlayer():getInventory():AddItem(AUD.Config.selectedVehicle:createVehicleKey())
        else
            getPlayer():Say("Vehicle not selected")
        end
    end

    local btn = ISButton:new(x, y, width, height, "Get key", nil, func)
    UIElement:addChild(btn);
end


function AUD.VehicleTab.addToggleHotwire(UIElement, x, y, width, height)
    local func = function(target, self)
        if AUD.Config.selectedVehicle then
            if AUD.Config.selectedVehicle:isHotwired() then
                AUD.Config.selectedVehicle:setHotwired(false)
            else
                AUD.Config.selectedVehicle:setHotwired(true)
            end
        else
            getPlayer():Say("Vehicle not selected")
        end
    end

    local btn = ISButton:new(x, y, width, height, "Toggle hotwire", nil, func)
    UIElement:addChild(btn);
end

function AUD.VehicleTab.addSelectVehicle(UIElement, x, y, width, height)
    local func = function(target, self)
        if AUD.Config.isSelectVehicle then
            AUD.Config.isSelectVehicle = false
        else
            AUD.Config.isSelectVehicle = true
        end
    end

    local btn = ISButton:new(x, y, width, height, "Select vehicle", nil, func)
    UIElement:addChild(btn);
end

function AUD.VehicleTab.addSelectThisVehicle(UIElement, x, y, width, height)
    local func = function(target, self)
        local pl = getPlayer()
        local veh = pl:getVehicle()

        if veh then
            AUD.Config.selectedVehicle = veh
            pl:Say(getText("IGUI_VehicleName" .. veh:getScript():getName()) .. " selected")
        else
            pl:Say("Player not in vehicle")
        end
    end

    local btn = ISButton:new(x, y, width, height, "Select this vehicle", nil, func)
    UIElement:addChild(btn);
end

function AUD.VehicleTab.addSpawnVehicle(UIElement, x, y, width, height)
    local func = function(target, self)
        local modal = AUDSpawnVehiclePanel:new(Core:getInstance():getScreenWidth() - 290, Core:getInstance():getScreenHeight() - 285 - 40 - 400, 250, 300, nil, ISPlayerStatsUI.onAddTrait)
        modal:initialise();
        modal:addToUIManager();
    end

    local btn = ISButton:new(x, y, width, height, "Spawn vehicle", nil, func)
    UIElement:addChild(btn);
end
