--local util = require "Util_Functions_Community_client.lua"
local util = {}

function util.markAllStasBuildingshOnMap(show,clear)
    if show then ISWorldMap.ShowWorldMap(0)
    elseif not ISWorldMap_instance then ISWorldMap.ShowWorldMap(0)
    end

    local symbols = ISWorldMap_instance.mapAPI:getSymbolsAPI()
    if clear then
        symbols:clear()
        --WorldMapVisited.getInstance():forget()
    end
    for _,stash in ipairs(StashDescriptions) do
        if stash.buildingX and stash.buildingY then
            local symbol = symbols:addTexture("DollarSign",stash.buildingX,stash.buildingY)
            symbol:setScale(1.2)
            symbol:setRGBA(1,1,0.8,1)
            symbol:setAnchor(0.5, 0.5)
        else
            print("no building x/y for stash",stash.name)
        end
    end
end

return util