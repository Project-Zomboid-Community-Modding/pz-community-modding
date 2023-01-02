require("AUD/Init")
AUD.InspectorSettings = {}

AUDInspectorSettingsTab = ISPanelJoypad:derive("AUDInspectorSettingsTab")

function AUDInspectorSettingsTab:initialise()
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

    AUD.InspectorSettings.addInspectorParamViewSetting(self, AUD.Config.Buttons.LeftIndent, AUD.Config.Buttons.TopIndent, AUD.Config.Buttons.Width, AUD.Config.Buttons.Height)
    AUD.InspectorSettings.addInspectorClear(self, AUD.Config.Buttons.LeftIndent, AUD.Config.Buttons.TopIndent + AUD.Config.Buttons.VerticalStep, AUD.Config.Buttons.Width, AUD.Config.Buttons.Height)        
end


function AUD.InspectorSettings.addInspectorParamViewSetting(UIElement, x, y, width, height)
    local func = function(target, self)
        if AUD.Inspector.paramsMode == "NORMAL" then
            AUD.Inspector.paramsMode = "TABLE_STATIC"
            self:setTitle("Table static view")
        elseif AUD.Inspector.paramsMode == "TABLE_STATIC" then
            AUD.Inspector.paramsMode = "TABLE_DYNAMIC"
            self:setTitle("Table dynamic view")
        elseif AUD.Inspector.paramsMode == "TABLE_DYNAMIC" then
            AUD.Inspector.paramsMode = "NORMAL"
            self:setTitle("Normal view")
        end
        self:update()
    end

    local text = "UNDEF"
    if AUD.Inspector.paramsMode == "NORMAL" then
        text = "Normal view"
    elseif AUD.Inspector.paramsMode == "TABLE_STATIC" then
        text = "Table static view"
    elseif AUD.Inspector.paramsMode == "TABLE_DYNAMIC" then
        text = "Table dynamic view"
    end

    local btn = ISButton:new(x, y, width, height, text, nil, func);
    UIElement:addChild(btn);
end

function AUD.InspectorSettings.addInspectorClear(UIElement, x, y, width, height)
    local func = function(target, self)
        AUD.Inspector.TabsData = {}
    end

    local btn = ISButton:new(x, y, width, height, "Clear", nil, func);
    UIElement:addChild(btn);
end