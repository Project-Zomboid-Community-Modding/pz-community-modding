--[[ bugfix ]]
---ISItemsListViewer doesn't show icons for mod items because getTexture returns nil
---trygetTexture needs nil check compared to original
local original_getTexture = getTexture
function getTexture(fileName)
    if fileName == nil then return nil end
    return original_getTexture(fileName) or Texture.trygetTexture(fileName)
end
