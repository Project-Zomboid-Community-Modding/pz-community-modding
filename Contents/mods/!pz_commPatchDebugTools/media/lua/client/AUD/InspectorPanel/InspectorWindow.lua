require("AUD/Init")

AUD.Inspector = {}
AUD.Inspector.Tabs = {}
AUD.Inspector.TabsData = {}

AUD.Inspector.paramsMode = "NORMAL"

AUDInspector = ISTabPanel:derive("AUDInspector")

function AUDInspector:initialise()
    ISTabPanel.initialise(self);

    self:setAnchorBottom(true);
    self:setAnchorRight(true);
    self.target = self;
    self:setEqualTabWidth(true)
    self:setCenterTabs(true)
    AUD.inspectorWindow = self:wrapInCollapsableWindow("Inspector");
    
    local closeFunc = function(obj)
        AUD.InspectorPanel.lastX = AUD.inspectorWindow.x
        AUD.InspectorPanel.lastY = AUD.inspectorWindow.y
        AUD.InspectorPanel.lastWidth = AUD.inspectorWindow.width
        AUD.InspectorPanel.lastHeight = AUD.inspectorWindow.height - 24
        AUD.InspectorPanel.lastPosSaved = true

        ISCollapsableWindow.close(obj);
        AUD.inspectorWindow:setRemoved(true)
        AUD.InspectorPanel.toolbarButton:setImage(AUD.InspectorPanel.texture_Off)
    end
    
    AUD.inspectorWindow.close = closeFunc
    AUD.inspectorWindow.closeButton.onmousedown = closeFunc
    AUD.inspectorWindow:setResizable(true);

    for name, _ in pairs(AUD.Inspector.TabsData) do
        AUD.paramTypeTab = AUDInspectorTab:new(0, 48, AUD.inspectorWindow:getWidth(), AUD.inspectorWindow:getHeight() - AUD.inspectorWindow.nested.tabHeight)
        AUD.paramTypeTab:initialise()
        AUD.paramTypeTab.values = AUD.Inspector.TabsData[name]
        AUD.inspectorWindow.nested:addView(name, AUD.paramTypeTab)
    end

    AUD.inspectorSettingsTab = AUDInspectorSettingsTab:new(0, 48, AUD.inspectorWindow:getWidth(), AUD.inspectorWindow:getHeight() - AUD.inspectorWindow.nested.tabHeight)
    AUD.inspectorSettingsTab:initialise()
    AUD.inspectorWindow.nested:addView("Settings", AUD.inspectorSettingsTab)

    AUD.inspectorWindow:addToUIManager();

    AUD.InspectorPanel.toolbarButton:setImage(AUD.InspectorPanel.texture_On)
end


--------

function AUD.insp(tabName, paramName, arg1, arg2, arg3, arg4, arg5, arg6)
    if AUD.Inspector.TabsData[tabName] == nil then
        AUD.Inspector.TabsData[tabName] = {}

        if AUD.inspectorWindow then
            AUD.paramTypeTab = AUDInspectorTab:new(0, 48, AUD.inspectorWindow:getWidth(), AUD.inspectorWindow:getHeight() - AUD.inspectorWindow.nested.tabHeight)
            AUD.paramTypeTab:initialise()
            AUD.paramTypeTab.values = AUD.Inspector.TabsData[tabName]
            AUD.inspectorWindow.nested:addView(tabName, AUD.paramTypeTab)
        end

    end

    local t = {}
    table.insert(t, paramName)
    table.insert(t, arg1)
    table.insert(t, arg2)
    table.insert(t, arg3)
    table.insert(t, arg4)
    table.insert(t, arg5)
    table.insert(t, arg6)

    local lastNotNil = 0

    if paramName ~= nil then lastNotNil = 1 end
    if arg1 ~= nil then lastNotNil = 2 end
    if arg2 ~= nil then lastNotNil = 3 end
    if arg3 ~= nil then lastNotNil = 4 end
    if arg4 ~= nil then lastNotNil = 5 end
    if arg5 ~= nil then lastNotNil = 6 end
    if arg6 ~= nil then lastNotNil = 7 end

    for i=1, lastNotNil do
        if t[i] == nil then
            t[i] = "nil"
        end
    end

    AUD.Inspector.TabsData[tabName][paramName] = t
end

