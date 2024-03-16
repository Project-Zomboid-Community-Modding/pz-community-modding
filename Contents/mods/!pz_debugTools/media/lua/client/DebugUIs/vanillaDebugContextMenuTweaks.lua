require "DebugUIs/DebugContextMenu"
require "ISUI/ISWorldObjectContextMenu"


function DebugContextMenu.GetAllDeadBodies(playerObj)

    local squares = {}
    local doneSquares = {}

    local pSquare = playerObj:getSquare()

    ISWorldObjectContextMenu.getSquaresInRadius(pSquare:getX(), pSquare:getY(), pSquare:getZ(), 45, doneSquares, squares)

    local bodies = {}

    for _,sq in pairs(squares) do
        ---@type IsoGridSquare
        local square = sq
        local bodiesOnSq = square and square:getDeadBodys()
        if bodiesOnSq then
            for i = bodiesOnSq:size()-1, 0, -1 do
                local body = bodiesOnSq:get(i)
                bodies[body] = true
            end
        end
    end

    return bodies
end


---@param playerObj IsoPlayer|IsoGameCharacter|IsoMovingObject|IsoObject
function DebugContextMenu.OnRemoveAllCorpses(playerObj)

    local bodies = DebugContextMenu.GetAllDeadBodies(playerObj)

    for b,_ in pairs(bodies) do
        ---@type IsoDeadBody|IsoMovingObject|IsoObject
        local body = b
        body:getSquare():removeCorpse(body, false)
    end
end


---@param playerObj IsoPlayer|IsoGameCharacter|IsoMovingObject|IsoObject
function DebugContextMenu.OnReanimateAllCorpses(playerObj)
    local bodies = DebugContextMenu.GetAllDeadBodies(playerObj)
    for b,_ in pairs(bodies) do b:reanimateNow() end
end


---@param playerObj IsoPlayer|IsoGameCharacter|IsoMovingObject|IsoObject
function DebugContextMenu.OnBringCorpsesToMe(playerObj)

    local pSq = playerObj:getSquare()

    local bodies = DebugContextMenu.GetAllDeadBodies(playerObj)
    for b,_ in pairs(bodies) do
        ---@type IsoDeadBody|IsoMovingObject|IsoObject
        local body = b

        local bodyItem = playerObj:getInventory():AddItem(body:getItem())
        body:getSquare():removeCorpse(body, false)
        local dropX,dropY,dropZ = ISInventoryTransferAction.GetDropItemOffset(playerObj, pSq, bodyItem)
        playerObj:getCurrentSquare():AddWorldInventoryItem(bodyItem, dropX, dropY, dropZ)
        playerObj:getInventory():Remove(bodyItem)
    end
    ISInventoryPage.renderDirty = true
end


function DebugContextMenu.OnKillAllZombies()
    local zombies = getCell():getZombieList()
    for i = zombies:size()-1, 0, -1 do
        ---@type IsoZombie|IsoGameCharacter|IsoMovingObject|IsoObject
        local zombie = zombies:get(i)
        zombie:die()
    end
end


function DebugContextMenu.OnUnselectZombie() DebugContextMenu.selectedZombie = nil end

---@param context ISContextMenu
local function tweakedDebugMenu(player, context, worldobjects, test)

    local playerObj = getSpecificPlayer(player)

    local square = nil
    for i,v in ipairs(worldobjects) do square = v:getSquare() break end


    ---@type ISContextMenu
    local zombiesOption = context:getOptionFromName("Zombies")
    if zombiesOption then

        local zombieSubmenu = context:getSubMenu(zombiesOption.subOption)

        zombieSubmenu:addOption("Horde Manager", square, DebugContextMenu.onHordeManager, playerObj)
        if DebugContextMenu.selectedZombie then
            zombieSubmenu:insertOptionAfter("Remove All", "Unselect", nil, DebugContextMenu.OnUnselectZombie)
        end
        zombieSubmenu:insertOptionBefore("Horde Manager", "Kill All Zombies", playerObj, DebugContextMenu.OnKillAllZombies)

    end

    local bodiesOption = context:insertOptionAfter("Zombies", "Bodies", nil)
    if bodiesOption then
        bodiesOption.iconTexture = getTexture("media/ui/BugIcon.png")
        local bodiesSubMenu = ISContextMenu:getNew(context)
        context:addSubMenu(bodiesOption, bodiesSubMenu)

        bodiesSubMenu:addOption("Remove All Bodies", playerObj, DebugContextMenu.OnRemoveAllCorpses)
        bodiesSubMenu:addOption("Reanimate All Dead", playerObj, DebugContextMenu.OnReanimateAllCorpses)
        bodiesSubMenu:addOption("Move All Bodies (To Self)", playerObj, DebugContextMenu.OnBringCorpsesToMe)
    end

    ---@type ISContextMenu
    local mainOption = context:getOptionFromName("Main")
    if mainOption then

        local mainSubmenu = context:getSubMenu(mainOption.subOption)
        if mainSubmenu then
            mainSubmenu:removeOptionByName("Horde Manager")
        end
    end


    ---@type ISContextMenu
    local deadBodyOption = context:getOptionFromName("DeadBody")
    if deadBodyOption then

        local deadBodySubmenu = context:getSubMenu(deadBodyOption.subOption)
        if deadBodySubmenu then
            deadBodySubmenu:addOption("Remove All", playerObj, DebugContextMenu.OnRemoveAllCorpses)
        end
    end
end

Events.OnFillWorldObjectContextMenu.Add(tweakedDebugMenu)