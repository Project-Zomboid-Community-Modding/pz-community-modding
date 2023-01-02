require("AUD/Init")
AUD.DebugPanel = {}

AUD.DebugPanel.activeView = 1
AUD.DebugPanel.activeViews = {
        [1] = "Main",
        [2] = "Vehicle",
    }

AUD.DebugPanel.lastX = -1
AUD.DebugPanel.lastY = -1
AUD.DebugPanel.lastWidth = -1
AUD.DebugPanel.lastHeight = -1
AUD.DebugPanel.lastPosSaved = false
    
AUD.DebugPanel.texture_DebugPanel_On = getTexture("media/textures/_mainMenuButton_On.png")
AUD.DebugPanel.texture_DebugPanel_Off = getTexture("media/textures/_mainMenuButton_Off.png")


function AUD.DebugPanel.close(self)
    AUD.DebugPanel.lastX = AUD.debugPanelWindow.x
    AUD.DebugPanel.lastY = AUD.debugPanelWindow.y
    AUD.DebugPanel.lastWidth = AUD.debugPanelWindow.width
    AUD.DebugPanel.lastHeight = AUD.debugPanelWindow.height - 24
    AUD.DebugPanel.lastPosSaved = true

    AUD.DebugPanel.activeView = AUD.debugPanelTabPanel:getActiveViewIndex()
    ISCollapsableWindow.close(self);
    AUD.DebugPanel.toolbarButton:setImage(AUD.DebugPanel.texture_DebugPanel_Off);
    AUD.debugPanelWindow:setRemoved(true)
end

function AUD.DebugPanel.loadTabs()
    AUD.DebugPanel.mainTab = AUDMainTab:new(0, 48, AUD.debugPanelWindow:getWidth(), AUD.debugPanelWindow:getHeight() - AUD.debugPanelWindow.nested.tabHeight)
    AUD.DebugPanel.mainTab:initialise()
    AUD.debugPanelWindow.nested:addView("Main", AUD.DebugPanel.mainTab)

    AUD.vehicleTab = AUDVehicleTab:new(0, 48, AUD.debugPanelWindow:getWidth(), AUD.debugPanelWindow:getHeight() - AUD.debugPanelWindow.nested.tabHeight)
    AUD.vehicleTab:initialise()
    AUD.debugPanelWindow.nested:addView("Vehicle", AUD.vehicleTab)

    AUD.customTab = AUDCustomTab:new(0, 48, AUD.debugPanelWindow:getWidth(), AUD.debugPanelWindow:getHeight() - AUD.debugPanelWindow.nested.tabHeight)
    AUD.customTab:initialise()
    AUD.debugPanelWindow.nested:addView("Custom", AUD.customTab)
end

function AUD.DebugPanel.show()
    if not AUD.DebugPanel.lastPosSaved then
        AUD.DebugPanel.lastX = Core:getInstance():getScreenWidth() - 220
        AUD.DebugPanel.lastY = Core:getInstance():getScreenHeight() - 290
        AUD.DebugPanel.lastWidth = 185
        AUD.DebugPanel.lastHeight = 238
        AUD.DebugPanel.lastPosSaved = true
    end


    AUD.debugPanelTabPanel = ISTabPanel:new(AUD.DebugPanel.lastX, AUD.DebugPanel.lastY, AUD.DebugPanel.lastWidth, AUD.DebugPanel.lastHeight)
    AUD.debugPanelTabPanel:initialise();
    AUD.debugPanelTabPanel:setAnchorBottom(true);
    AUD.debugPanelTabPanel:setAnchorRight(true);
    AUD.debugPanelTabPanel.target = self;
    AUD.debugPanelTabPanel:setEqualTabWidth(true)
    --AUD.debugPanelTabPanel:setCenterTabs(true)
    AUD.debugPanelWindow = AUD.debugPanelTabPanel:wrapInCollapsableWindow("AUD");
    
    AUD.debugPanelWindow.close = AUD.DebugPanel.close
    AUD.debugPanelWindow.closeButton.onmousedown = AUD.DebugPanel.close

    AUD.debugPanelWindow:setResizable(true);

    AUD.DebugPanel.loadTabs()

    AUD.debugPanelWindow:addToUIManager();
    AUD.DebugPanel.toolbarButton:setImage(AUD.DebugPanel.texture_DebugPanel_On);
end






--------------------------------------------------------

local function debugPanelToggle()
    if AUD.debugPanelWindow and AUD.debugPanelWindow:getIsVisible() then
        AUD.debugPanelWindow:close();
	else
        AUD.DebugPanel.show()
        AUD.debugPanelTabPanel:activateView(AUD.DebugPanel.activeViews[AUD.DebugPanel.activeView])
	end
end

function AUD.DebugPanel.debugPanelWindowButton()
    local movableBtn = ISEquippedItem.instance.movableBtn;
	AUD.DebugPanel.toolbarButton = ISCustomButton:new(2, movableBtn:getY() + movableBtn:getHeight() + 150, 48, 48, "", nil, debugPanelToggle);
	AUD.DebugPanel.toolbarButton:setImage(AUD.DebugPanel.texture_DebugPanel_Off)
	AUD.DebugPanel.toolbarButton:setDisplayBackground(false);
    AUD.DebugPanel.toolbarButton.borderColor = {r=1, g=1, b=1, a=0.1};

	ISEquippedItem.instance:addChild(AUD.DebugPanel.toolbarButton)
    ISEquippedItem.instance:setHeight(Core:getInstance():getScreenHeight());
end



---------------------

ISCustomButton = ISButton:derive("ISCustomButton");

function ISCustomButton:onRightMouseUp(x, y)
    AUD.RestoreLayout.saveWindowsLayout()
end

