function DebugScenarios:createChildren()
    self.header = ISLabel:new(self.width / 2, 0, 40, "SCENARIOS", 1,1,1,1, UIFont.Large, true);
    self.header.center = true;
    self:addChild(self.header);

    local listY = self.header:getBottom()
    self.listbox = ISScrollingListBox:new(16, listY, self:getWidth()-32, self:getHeight()-16-listY);
    self.listbox:initialise();
    self.listbox:instantiate();
    self.listbox:setFont(UIFont.Medium, 2);
    self.listbox.drawBorder = true;
    self.listbox.doDrawItem = DebugScenarios.drawItem;
    self.listbox:setOnMouseDownFunction(self, DebugScenarios.onClickOption);
    self:addChild(self.listbox);

    for k,v in pairs(debugScenarios) do
        if v.isCustom then
            self.listbox:addItem(v.name, k);
        end
    end

    self.traitsSelector = ISTickBox:new(20, self.height - 20, 100, 18, "", self, DebugScenarios.onChangeList);
    self.traitsSelector:initialise();
    self.traitsSelector:instantiate();
    self.traitsSelector:setAnchorLeft(true);
    self.traitsSelector:setAnchorRight(false);
    self.traitsSelector:setAnchorTop(true);
    self.traitsSelector:setAnchorBottom(false);
    self.traitsSelector.selected[1] = false;
    self.traitsSelector:addOption("Default scenarios");
    self:addChild(self.traitsSelector);

    self:setMaxDrawHeight(self.header:getBottom())
end

function DebugScenarios:onChangeList()
    if self.traitsSelector.selected[1] then
        self.listbox:clear()
        for k,v in pairs(debugScenarios) do
            self.listbox:addItem(v.name, k);
        end
    else
        self.listbox:clear()
        for k,v in pairs(debugScenarios) do
            if v.isCustom then
                self.listbox:addItem(v.name, k);
            end
        end
    end    
end


function DebugScenarios:onClickOption(option)
    local scenario = debugScenarios[option];
    self:launchScenario(scenario);
end