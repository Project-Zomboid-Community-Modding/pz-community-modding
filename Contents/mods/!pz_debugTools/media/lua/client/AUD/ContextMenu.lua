local function showModData(obj, name)
    isoObjectInspect.OnOpenPanel(obj, name)
end


local modDataContextClasses ={
    ["IsoDeadBody"] = function(object) return object:getOutfitName() end,
    ["IsoPlayer"] = function(object) return object:getUsername(true) end,
    ["IsoZombie"] = function(object) return object:getOutfitName() end,
    ["BaseVehicle"] = function(object) return object:getScript():getName() end,
}


local function fillModDataContextMenu(array,contextMenu)
    for i=0,array:size()-1 do
        local object = array:get(i)
        local optionAdded = false
        for type,func in pairs(modDataContextClasses) do
            if instanceof(object, type) then
                local optionName = func(object)
                if optionName then optionName = ": "..optionName end
                local setName = type..(optionName or "")
                contextMenu:addOption(setName, object, showModData, setName)
                optionAdded = true
            end
        end

        if not optionAdded then
            local objName = tostring(object:getClass())
            contextMenu:addOption(objName, object, showModData, objName)
        end
    end
end


local function AUDContextMenu(player, context, worldObjects, test)
    local sq
    local mainMenu = context:addOptionOnTop("Inspect", worldObjects, nil)
    local subMenu = ISContextMenu:getNew(context)
    context:addSubMenu(mainMenu, subMenu)

    for i,object in ipairs(worldObjects) do
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

            local objName = "IsoObject"..(customName or "")
            subMenu:addOption(objName, object, showModData, objName)
        end
    end

    if sq ~= nil then
        for x=sq:getX()-1, sq:getX()+1 do
            for y=sq:getY()-1, sq:getY()+1 do
                local sq2 = getCell():getGridSquare(x, y, sq:getZ())
                if sq2 then
                    local staticMovingObjects = sq2:getStaticMovingObjects()
                    fillModDataContextMenu(staticMovingObjects,subMenu)

                    local movingObjects = sq2:getMovingObjects()
                    fillModDataContextMenu(movingObjects,subMenu)
                end
            end
        end
    end

end
Events.OnFillWorldObjectContextMenu.Add(AUDContextMenu)


local function AUDInvContextMenu(player, context, items)
    for i,v in ipairs(items) do
		local item = v
        if not instanceof(v, "InventoryItem") then item = v.items[1] end
        context:addOptionOnTop("Inspect", item, showModData)
	end
end
Events.OnFillInventoryObjectContextMenu.Add(AUDInvContextMenu)