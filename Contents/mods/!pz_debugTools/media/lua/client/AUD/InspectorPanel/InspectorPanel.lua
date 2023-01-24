require("AUD/Init")
AUD.InspectorPanel = {}

AUD.InspectorPanel.texture_On = getTexture("media/textures/_ValueInspector_On.png")
AUD.InspectorPanel.texture_Off = getTexture("media/textures/_ValueInspector_Off.png")


local function inspectorWindowToggle()
    if AUD.inspectorWindow and AUD.inspectorWindow:getIsVisible() then
        AUD.inspectorWindow:close()
    else
        AUD.inspectorWindowTabPanel = AUDInspector:new(100, 100, 400, 250)
        AUD.inspectorWindowTabPanel:initialise()
	end
end

function AUD.InspectorPanel.inspectorButton()
    AUD.setNewButton(ISButton, AUD.InspectorPanel, inspectorWindowToggle)
end