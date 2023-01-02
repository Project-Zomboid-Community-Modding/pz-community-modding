require("AUD/Init")
AUD.CustomTabTable = {}
AUD.CustomTabTable.Buttons = {}

AUDCustomTab = ISPanelJoypad:derive("AUDCustomTab")

function AUDCustomTab:initialise()
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

    local x = AUD.Config.Buttons.LeftIndent
    local y =  AUD.Config.Buttons.TopIndent
    local yStep = AUD.Config.Buttons.VerticalStep
    local width = AUD.Config.Buttons.Width
    local height = AUD.Config.Buttons.Height

    for i=1, 6 do
        if AUD.CustomTabTable.Buttons[i] == nil then
            AUD.CustomTabTable.Buttons[i] = {}
            AUD.CustomTabTable.Buttons[i].name = "Button " .. i
        end
        AUD.CustomTabTable.Buttons[i].button = ISButton:new(x, y + yStep*(i-1), width, height, AUD.CustomTabTable.Buttons[i].name, nil, nil)
        AUD.CustomTabTable.Buttons[i].button:setOnClick(AUD.CustomTabTable.Buttons[i].func, AUD.CustomTabTable.Buttons[i].arg1, AUD.CustomTabTable.Buttons[i].arg2, AUD.CustomTabTable.Buttons[i].arg3, AUD.CustomTabTable.Buttons[i].arg4)
        self:addChild(AUD.CustomTabTable.Buttons[i].button)
    end
end


function AUD.setButton(num, name, func, arg1, arg2, arg3, arg4)
    if num > 6 or num < 1 then return end

    if AUD.CustomTabTable.Buttons[num] == nil then
        AUD.CustomTabTable.Buttons[num] = {}
    end
    AUD.CustomTabTable.Buttons[num].name = name
    AUD.CustomTabTable.Buttons[num].func = function(_, _, a, b, c, d) func(a, b, c, d) end
    AUD.CustomTabTable.Buttons[num].arg1 = arg1
    AUD.CustomTabTable.Buttons[num].arg2 = arg2
    AUD.CustomTabTable.Buttons[num].arg3 = arg3
    AUD.CustomTabTable.Buttons[num].arg4 = arg4

    if AUD.debugPanelWindow and AUD.debugPanelWindow:getIsVisible() then
        if AUD.CustomTabTable.Buttons[num].button then
            AUD.CustomTabTable.Buttons[num].button:setTitle(name)
            AUD.CustomTabTable.Buttons[num].button:setOnClick(AUD.CustomTabTable.Buttons[num].func, AUD.CustomTabTable.Buttons[num].arg1, AUD.CustomTabTable.Buttons[num].arg2, AUD.CustomTabTable.Buttons[num].arg3, AUD.CustomTabTable.Buttons[num].arg4)
        end
    end
end