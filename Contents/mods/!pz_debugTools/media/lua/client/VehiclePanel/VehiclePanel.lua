--TODO: Consolidate this menu into the vanilla menu as per 

require "InitToolBar"
require "ButtonPanel"

VehiclePanel = ButtonPanelUI:derive("VehiclePanel")


function VehiclePanel:OnOpenPanel()
    if not getDebug() then return end
    VehiclePanel.title = "Vehicle"
    ButtonPanelUI.OnOpenPanel("VehiclePanel")
end


local function openOnStart()
    if not getDebug() then return end
    VehiclePanel:OnOpenPanel()
end
Events.OnCreatePlayer.Add(openOnStart)


local vehicleDebugFunctions = require "VehiclePanel/VehicleFunctions"
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

local ISDebugMenu_setupButtons = ISDebugMenu.setupButtons
function ISDebugMenu:setupButtons()
    ISDebugMenu_setupButtons(self)
    self:addButtonInfoAfter("Cheats", "Vehicle", function() VehiclePanel.OnOpenPanel() end, "MAIN")
end
