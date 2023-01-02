local function showModData(obj) ModDataDebugPanel.OnOpenPanel(obj) end


local function AUDContextMenu(player, context, worldobjects, test)
    local sq = nil


    local mainMenu = context:addOptionOnTop("Inspect ModData", worldobjects, nil)
    local subMenu = ISContextMenu:getNew(context)
    context:addSubMenu(mainMenu, subMenu)


    for i,object in ipairs(worldobjects) do
        local square = object:getSquare()
        if square and sq == nil then sq = square end
        if instanceof(object, "IsoObject") and (not instanceof(object, "IsoWorldInventoryObject")) then

            local objectSprite = object:getSprite()
            local props = objectSprite and objectSprite:getProperties()

            local customName = props and props:Is("CustomName") and props:Val("CustomName")
            if customName then
                if props:Is("GroupName") then customName = props:Val("GroupName").." "..customName end
                customName = ": "..customName
            else
                local spriteName = objectSprite and objectSprite:getName()
                customName = ": "..spriteName or tostring(object:getClass())
            end

            subMenu:addOptionOnTop("IsoObject"..(customName or ""), object, showModData)
        end
    end

    if sq ~= nil then
        for x=sq:getX()-1, sq:getX()+1 do
            for y=sq:getY()-1, sq:getY()+1 do
                local sq2 = getCell():getGridSquare(x, y, sq:getZ());
                if sq2 then
                    for i=0,sq2:getMovingObjects():size()-1 do
                        local object = sq2:getMovingObjects():get(i)

                        if instanceof(object, "IsoPlayer") then
                            local isoPlayerName = object:getUsername(true)
                            if isoPlayerName then isoPlayerName = ": "..isoPlayerName end
                            subMenu:addOption("IsoPlayer"..(isoPlayerName or ""), object, showModData)

                        elseif instanceof(object, "IsoZombie") then
                            local outfitName = object:getOutfitName()
                            if outfitName then outfitName = ": "..outfitName end
                            subMenu:addOption("IsoZombie"..(outfitName or ""), object, showModData)

                        elseif instanceof(object, "BaseVehicle") then
                            subMenu:addOption("Vehicle: "..object:getScript():getName(), object, showModData)
                        end
                    end
                end
            end
        end
    end

end
Events.OnFillWorldObjectContextMenu.Add(AUDContextMenu);


local function AUDInvContextMenu(player, context, items)
    for i,v in ipairs(items) do
		local item = v;
        if not instanceof(v, "InventoryItem") then item = v.items[1]; end
        context:addOptionOnTop("Inspect Item ModData", item, showModData);
	end
end
Events.OnFillInventoryObjectContextMenu.Add(AUDInvContextMenu)