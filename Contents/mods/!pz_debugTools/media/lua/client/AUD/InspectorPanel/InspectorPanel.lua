require("AUD/Init")
AUD.InspectorPanel = {}

AUD.InspectorPanel.lastX = -1
AUD.InspectorPanel.lastY = -1
AUD.InspectorPanel.lastWidth = -1
AUD.InspectorPanel.lastHeight = -1
AUD.InspectorPanel.lastPosSaved = false

AUD.InspectorPanel.texture_On = getTexture("media/textures/_ValueInspector_On.png")
AUD.InspectorPanel.texture_Off = getTexture("media/textures/_ValueInspector_Off.png")


local function inspectorWindowToggle()
    if AUD.inspectorWindow and AUD.inspectorWindow:getIsVisible() then
        AUD.inspectorWindow:close();
    else
        if not AUD.InspectorPanel.lastPosSaved then
            AUD.InspectorPanel.lastX = Core:getInstance():getScreenWidth() - 680
            AUD.InspectorPanel.lastY = Core:getInstance():getScreenHeight() - 620
            AUD.InspectorPanel.lastWidth = 640
            AUD.InspectorPanel.lastHeight = 248
            AUD.InspectorPanel.lastPosSaved = true
        end

        AUD.inspectorWindowTabPanel = AUDInspector:new(AUD.InspectorPanel.lastX, AUD.InspectorPanel.lastY, AUD.InspectorPanel.lastWidth, AUD.InspectorPanel.lastHeight);
        AUD.inspectorWindowTabPanel:initialise()
	end
end

function AUD.InspectorPanel.inspectorButton()
    AUD.setNewButton(ISButton, AUD.InspectorPanel, inspectorWindowToggle)
end