local function showModData(obj, name)
    isoObjectInspect.OnOpenPanel(obj, name)
end



local modDataContextClasses ={
    --- @TODO: make a better patch to handle IsoAnimal dead bodies not having HumanVisual, which throws an error internal in getOutfitName
    ["IsoDeadBody"] = function(object) if object:getHumanVisual() then return object:getOutfitName() end return nil end,
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


local function ContextMenu(player, context, worldObjects, test)
    if not getDebug() then return end
    local sq
    local mainMenu = context:addOptionOnTop("Inspect", worldObjects, nil)
    mainMenu.iconTexture = getTexture("media/textures/_IsoObjInspect.png")
    local subMenu = ISContextMenu:getNew(context)
    context:addSubMenu(mainMenu, subMenu)

    for i,object in ipairs(worldObjects) do
        local square = object:getSquare()
        if square and sq == nil then sq = square end
        --if instanceof(object, "IsoObject") then

            local objectSprite = object:getSprite()
            local props = objectSprite and objectSprite:getProperties()

            local customName = props and props:Is("CustomName") and props:Val("CustomName")
            if customName then
                if props:Is("GroupName") then customName = props:Val("GroupName").." "..customName end
                customName = ": "..customName
            else
                local spriteName = objectSprite and objectSprite:getName()
                customName = ": ".. (spriteName or tostring(object:getClass()))
            end

            local objName = "IsoObject"..(customName or "")
            subMenu:addOption(objName, object, showModData, objName)
        --end
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
Events.OnFillWorldObjectContextMenu.Add(ContextMenu)


local function InvContextMenu(player, context, items)
    if not getDebug() then return end
    for i,v in ipairs(items) do
		local item = v
        if not instanceof(v, "InventoryItem") then item = v.items[1] end
        local option = context:addOptionOnTop("Inspect", item, showModData, item:getType())
        option.iconTexture = getTexture("media/textures/_IsoObjInspect.png")
        break
	end
end
Events.OnFillInventoryObjectContextMenu.Add(InvContextMenu)