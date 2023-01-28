require "AUD/DebugPanel/ButtonPanel"
VehiclePanel = ButtonPanelUI:derive("VehiclePanel")


function VehiclePanel:OnOpenPanel()
    VehiclePanel.title = "Vehicle"
    ButtonPanelUI.OnOpenPanel(VehiclePanel)
end


function VehiclePanel:initialise()
    ButtonPanelUI.initialise(self)
    ISLayoutManager.RegisterWindow('VehiclePanel', VehiclePanel, self)
end


local function openOnStart() VehiclePanel:OnOpenPanel() end
Events.OnCreatePlayer.Add(openOnStart)

local function onDeath() if VehiclePanel.instance then VehiclePanel.instance:close() end end
Events.OnPlayerDeath.Add(onDeath)


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


require "DebugUIs/DebugMenu/ISDebugMenu"
require "AUD/Init"
local ISDebugMenu_setupButtons = ISDebugMenu.setupButtons
function ISDebugMenu:setupButtons()
    ISDebugMenu_setupButtons(self)
    self:addButtonInfoAfter("Cheats", "Vehicle", function() VehiclePanel.OnOpenPanel() end, "MAIN")
end
