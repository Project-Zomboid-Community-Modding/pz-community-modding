require "AUD/DebugPanel/ButtonPanel"
ButtonedCheatPanelUI = ButtonPanelUI:derive("ButtonedCheatPanelUI")

function ButtonedCheatPanelUI:OnOpenPanel()
    ButtonedCheatPanelUI.title = "Cheats"
    ButtonPanelUI.OnOpenPanel(ButtonedCheatPanelUI)
end


require "DebugUIs/DebugMenu/General/ISCheatPanelUI"
function ISCheatPanelUI.OnOpenPanel()
    ButtonedCheatPanelUI:OnOpenPanel()
end


local function openOnStart() ButtonedCheatPanelUI:OnOpenPanel() end
Events.OnCreatePlayer.Add(openOnStart)


function ButtonedCheatPanelUI:initialise()
    ButtonPanelUI.initialise(self)
    ISLayoutManager.RegisterWindow('ButtonedCheatPanelUI', ButtonedCheatPanelUI, self)
end


local function forceInitCheatPanel()
    if ISCheatPanelUI.instance==nil then
        ISCheatPanelUI.instance = ISCheatPanelUI:new (-500, -500, 10, 10, getPlayer())
        ISCheatPanelUI.instance:initialise()
    end
    ISCheatPanelUI.instance:removeFromUIManager()
    ISCheatPanelUI.instance:setVisible(false)
    return ISCheatPanelUI.instance
end


local function cheatButtonSpecialFunc(button, cheatPanel, index)
    if cheatPanel and index then
        button.backgroundColor = cheatPanel.tickBox:isSelected(index) and AUD.Config.Buttons.GREEN or AUD.Config.Buttons.RED
        button.backgroundColorMouseOver = cheatPanel.tickBox:isSelected(index) and AUD.Config.Buttons.GREEN_HIGHLIGHT or AUD.Config.Buttons.RED_HIGHLIGHT
    end
end

local function decorateSetFunction(index, cheatPanel)
    return function(target, self)

        local isSelected = cheatPanel.tickBox:isSelected(index)
        if isSelected then
            cheatPanel.tickBox:setSelected(index, false)
        else
            cheatPanel.tickBox:setSelected(index, true)
        end
        cheatButtonSpecialFunc(self, cheatPanel, index)

        cheatPanel.setFunction[index](cheatPanel, cheatPanel.tickBox:isSelected(index))
        self:update()
    end
end


function ButtonedCheatPanelUI:handleAddButtons(x, y)

    local rows = 1
    local w = AUD.Config.Buttons.Width
    local h = AUD.Config.Buttons.Height
    local yStep = AUD.Config.Buttons.VerticalStep

    local cheatPanel = forceInitCheatPanel()
    for i=1,#cheatPanel.tickBox.options do
        local newFunc = decorateSetFunction(i, cheatPanel)
        local optionName = cheatPanel.tickBox.optionsIndex[i]
        self:addButton(newFunc, optionName, {cheatButtonSpecialFunc, cheatPanel, i}, x, y+(yStep*rows), w, h)
        rows = rows+1
    end

    self:addButton(function() self:close() end, "Close", nil, x, y+(yStep*(rows+0.75)), w, h)
    self:setHeight((y*2)+(yStep*(rows+1.5)))
end