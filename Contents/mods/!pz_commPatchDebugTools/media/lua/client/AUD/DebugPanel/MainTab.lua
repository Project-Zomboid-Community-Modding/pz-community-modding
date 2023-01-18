require("AUD/Init")
require("")
AUD.MainTabTable = {}

AUDMainTab = ISPanelJoypad:derive("AUDMainTab")


local function decorateSetFunction(index, cheatPanel)
    return function(target, self)

        local isSelected = cheatPanel.tickBox:isSelected(index)
        if isSelected then
            cheatPanel.tickBox:setSelected(index, false)
            self.backgroundColor = AUD.Config.Buttons.RED
        else
            cheatPanel.tickBox:setSelected(index, true)
            self.backgroundColor = AUD.Config.Buttons.GREEN
        end

        cheatPanel.setFunction[index](cheatPanel, cheatPanel.tickBox:isSelected(index))
        self:update()
    end
end


local function forceInitCheatPanel()
    if ISCheatPanelUI.instance==nil then
        ISCheatPanelUI.instance = ISCheatPanelUI:new (50, 200, 212, 350, getPlayer())
        ISCheatPanelUI.instance:initialise()
    end
    ISCheatPanelUI.instance:addToUIManager()
    ISCheatPanelUI.instance:setVisible(false)
    return ISCheatPanelUI.instance
end

local vehicleDebugFunctions = require "AUD/DebugPanel/VehicleTab/VehicleFunctions"

function AUDMainTab:initialise()
    ISPanelJoypad.initialise(self);

    self:instantiate()
    self:setAnchorRight(true)
    self:setAnchorLeft(true)
    self:setAnchorTop(true)
    self:setAnchorBottom(true)
    self:noBackground()

    self.borderColor = {r=0, g=0, b=0, a=0};

    local x = AUD.Config.Buttons.LeftIndent
    local y =  AUD.Config.Buttons.TopIndent
    local yStep = AUD.Config.Buttons.VerticalStep

    local rows = 0

    local cheatPanel = forceInitCheatPanel()
    for i=1,#cheatPanel.tickBox.options do
        local newFunc = decorateSetFunction(i, cheatPanel)
        local optionName = cheatPanel.tickBox.optionsIndex[i]
        AUD.MainTabTable.addCheat(self, newFunc, optionName, cheatPanel, i, x, y+(yStep*rows), AUD.Config.Buttons.Width, AUD.Config.Buttons.Height)
        rows = rows+1
    end

    for _,name_func in pairs(vehicleDebugFunctions) do
        local name, func = name_func()
        AUD.MainTabTable.addButton(self, func, name, nil, nil, x, y+(yStep*rows), AUD.Config.Buttons.Width, AUD.Config.Buttons.Height)
        rows = rows+1
    end

    self:setScrollChildren(true)
    self:addScrollBars()
end


function AUD.MainTabTable.addButton(UIElement, setFunction, title, cheatPanel, index, x, y, width, height)
    local btn = ISButton:new(x, y, width, height, title, nil, setFunction)
    if cheatPanel and index then btn.backgroundColor = cheatPanel.tickBox:isSelected(index) and AUD.Config.Buttons.GREEN or AUD.Config.Buttons.RED end
    UIElement:addChild(btn)
end