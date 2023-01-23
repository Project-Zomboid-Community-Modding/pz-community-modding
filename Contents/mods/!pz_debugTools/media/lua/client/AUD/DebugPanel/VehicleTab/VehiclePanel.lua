require "AUD/DebugPanel/ButtonPanel"
VehiclePanel = ButtonPanelUI:derive("VehiclePanel")

require "DebugUIs/DebugMenu/ISDebugMenu"
function VehiclePanel:OnOpenPanel()
    VehiclePanel.title = "Vehicle"
    ButtonPanelUI.OnOpenPanel(VehiclePanel)
end


local vehicleDebugFunctions = require "AUD/DebugPanel/VehicleTab/VehicleFunctions"
function VehiclePanel:handleAddButtons(x, y)

    local rows = 1
    local w = AUD.Config.Buttons.Width
    local h = AUD.Config.Buttons.Height
    local yStep = AUD.Config.Buttons.VerticalStep

    for _,name_func in pairs(vehicleDebugFunctions) do
        local name, func = name_func()
        self:addButton(func, name, nil, x, y+(yStep*rows), w, h)
        rows = rows+1
    end

    self:addButton(function() self:close() end, "Close", nil, x, y+(yStep*(rows+0.75)), w, h)
    self:setHeight((y*2)+(yStep*(rows+1.5)))
end


local ISDebugMenu_setupButtons = ISDebugMenu.setupButtons
function ISDebugMenu:setupButtons()
    self:addButtonInfo("Vehicle", function() VehiclePanel.OnOpenPanel() end, "MAIN")
    ISDebugMenu_setupButtons(self)
end