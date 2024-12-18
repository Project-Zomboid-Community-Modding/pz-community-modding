
local LightSourceMenuAPI = {}

local sliceTable = {}


function LightSourceMenuAPI.registerSlice(sliceName, sliceFunction)
    sliceTable[sliceName] = sliceFunction
end

function LightSourceMenuAPI.unregisterSlice(sliceName)
    sliceTable[sliceName] = nil
end

--modified version of the default LightSourceMenuAPI.fillMenu allowing editing of the radial menu
function ISLightSourceRadialMenu:fillMenu()
    local menu = getPlayerRadialMenu(self.playerNum)
    menu:clear()

    --local items = self.character:getInventory():getAllEvalRecurse(predicateLightSource, ArrayList.new())

    for _, f in pairs(sliceTable) do
        f(menu, self.character, self)
    end
end

------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------		Base Game Slices		------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------

local function predicateLightSource(item)
    -- getLightStrength() may be > 0 even though the battery is dead.
    return (item:getLightStrength() > 0) or (item:getFullType() == "Base.Candle")
end

LightSourceMenuAPI.registerSlice("Inventory", function(menu, player, instance)
    local items = player:getInventory():getAllEvalRecurse(predicateLightSource, ArrayList.new())

    local hasType = {}
    for i = 0, items:size() - 1 do
        local item = items:get(i)
        local fullType = item:getFullType()
        if hasType[fullType] then
            if not (fullType == "Base.Candle" or fullType == "Base.CandleLit" or fullType == "Base.Lantern_Hurricane" or fullType == "Base.Lantern_HurricaneLit") then
                local other = hasType[fullType]
                if item:canEmitLight() and not other:canEmitLight() then
                    hasType[fullType] = item
                end
            end
        else
            hasType[fullType] = item
        end
    end

    for _, item in pairs(hasType) do
        if not (player:isPrimaryHandItem(item) or player:isSecondaryHandItem(item)) then
            menu:addSlice(item:getDisplayName() .. "\n" .. getText("ContextMenu_Equip_Primary"), item:getTex(), ISLightSourceRadialMenu.onEquipLight, instance, item, true);
            menu:addSlice(item:getDisplayName() .. "\n" .. getText("ContextMenu_Equip_Secondary"), item:getTex(), ISLightSourceRadialMenu.onEquipLight, instance, item, false);
        end
    end
end)

LightSourceMenuAPI.registerSlice("Primary", function(menu, player, instance)
    local primary = player:getPrimaryHandItem()

    if primary and predicateLightSource(primary) then
        menu:addSlice(primary:getDisplayName() .. "\n" .. getText("ContextMenu_Unequip"), getTexture("media/ui/ZoomOut.png"), ISLightSourceRadialMenu.onEquipLight, instance, primary)
    end

    instance:fillMenuForItem(menu, primary)
end)

LightSourceMenuAPI.registerSlice("Secondary", function(menu, player, instance)
    local secondary = player:getSecondaryHandItem()

    if secondary and predicateLightSource(secondary) then
        menu:addSlice(secondary:getDisplayName() .. "\n" .. getText("ContextMenu_Unequip"), getTexture("media/ui/ZoomOut.png"), ISLightSourceRadialMenu.onEquipLight, instance, secondary)
    end

    instance:fillMenuForItem(menu, secondary)
end)

--local function onExample(player)
--	player:Say("This is a custom slice!")
--end
--
--local function exampleFunction(menu, player, weapon)
--	menu:addSlice("What's This?", getTexture("media/ui/emotes/shrug.png"), onExample, player)
--end
--
--LightSourceMenuAPI.registerSlice("example", exampleFunction)

return LightSourceMenuAPI
