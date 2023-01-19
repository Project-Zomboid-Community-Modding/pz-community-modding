require("AUD/Init")
require("")
AUD.MainTabTable = {}

AUDMainTab = ISPanel:derive("AUDMainTab")


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

local function cheatButtonSpecialFunc(button, cheatPanel, index)
    if cheatPanel and index then
        button.backgroundColor = cheatPanel.tickBox:isSelected(index) and AUD.Config.Buttons.GREEN or AUD.Config.Buttons.RED
    end
end

function AUDMainTab:initialise()
    ISPanel.initialise(self);

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
        AUD.MainTabTable.addButton(self, newFunc, optionName, {cheatButtonSpecialFunc, cheatPanel, i}, x, y+(yStep*rows), AUD.Config.Buttons.Width, AUD.Config.Buttons.Height)
        rows = rows+1
    end

    for _,name_func in pairs(vehicleDebugFunctions) do
        local name, func = name_func()
        AUD.MainTabTable.addButton(self, func, name, nil, x, y+(yStep*rows), AUD.Config.Buttons.Width, AUD.Config.Buttons.Height)
        rows = rows+1
    end

    self:setScrollChildren(true)
    self:addScrollBars()
end


function AUD.MainTabTable.addButton(UIElement, setFunction, title, specialFuncAndArgs, x, y, width, height)
    local btn = ISButton:new(x, y, width, height, title, nil, setFunction)

    local specialFunc = specialFuncAndArgs and specialFuncAndArgs[1]
    if specialFunc and type(specialFunc) == "function" then
        local args = {btn}
        for i=2, #specialFuncAndArgs do table.insert(args,specialFuncAndArgs[i]) end
        specialFunc(unpack(args))
    end

    UIElement:addChild(btn)
end