require "Entity/ISUI/CraftRecipe/ISTiledIconPanel"

local ISTiledIconPanel_setSearchInfoText = ISTiledIconPanel.setSearchInfoText
function ISTiledIconPanel:setSearchInfoText(_text)
	self.searchInfoText = _text
	if self.entryBox then ISTiledIconPanel_setSearchInfoText(self, _text) end
end
