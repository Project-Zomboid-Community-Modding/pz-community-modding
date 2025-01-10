------------------------------------------
-- Animation API
------------------------------------------
-- Animation API Definition
--- @table AnimAPI
local AnimAPI = {
    Debug = isDebugEnabled(),
    isClient = isClient(),
    playerData = {}
}

local _getPlayerID = (AnimAPI.isClient and __classmetatables[IsoPlayer.class].__index.getOnlineID) or __classmetatables[IsoPlayer.class].__index.getPlayerNum

------------------------------------------
--- Utilities
------------------------------------------
local addTable = function(data, key, value)
    data[key] = data[key] or {}
    data[key][#data[key]+1] = value
    AnimAPI._activateAnimAPI()
end

local addType = function(item, animation, data, funcName)
    assert(item and type(item) == "string", "ERROR " .. funcName .. ": Expected Item:getFullType() string, got: " .. tostring(item) .. " | Type: " .. type(item))
    assert((animation and (type(animation) == "table" or type(animation) == "function" or type(animation) == "string")), "ERROR " .. funcName .. ": Invalid animation data provided for: " .. item)
    addTable(data, item, animation)
end

local addWeaponType = function(weapontype, animation, data, funcName)
    assert(instanceof(weapontype, "WeaponType"), "ERROR " .. funcName .. ": " .. tostring(weapontype) .. " is not a valid WeaponType")
    assert((animation and (type(animation) == "table" or type(animation) == "function")), "ERROR " .. funcName .. ": Invalid animation data provided for: " .. tostring(weapontype))
    addTable(data, weapontype, animation)
end

local addTag = function(tag, animation, data, funcName)
    assert(tag and type(tag) == "string", "ERROR " .. funcName .. ": Expected string, got: " .. tostring(tag) .. " | Type: " .. type(tag))
    assert((animation and (type(animation) == "table" or type(animation) == "function" or type(animation) == "string")), "ERROR " .. funcName .. ": Invalid animation data provided for: " .. tag)
    addTable(data, tag, animation)
end

-- branded print for the player
local Say = function(character, err, ...)
-- do nothing
end

-- branded general print function
local Print = function(...)
-- do nothing
end

-- branded general print function
local Error = function(...)
-- do nothing
end

-- Only implement these functions in Debug mode
if AnimAPI.Debug then
    Print = function(...)
        local args = {...}
        local msg = ""
        -- table.concat was considered, but I don't want to restrict myself to only string/integers here.
        for i=1,#args do
            msg = msg .. " " .. tostring(args[i])
        end
        print("?ANIMAPI: " .. msg)
    end
    Error = function(...)
        local args = {...}
        local msg = ""
        -- table.concat was considered, but I don't want to restrict myself to only string/integers here.
        for i=1,#args do
            msg = msg .. " " .. tostring(args[i])
        end
        print("!ANIMAPI: " .. msg)
    end
    Say = function(character, err, ...)
        local args = {...}
        local msg = ""
        -- table.concat was considered, but I don't want to restrict myself to only string/integers here.
        for i=1,#args do
            msg = msg .. " " .. tostring(args[i])
        end
        character:Say(((err and "!ANIMAPI: ") or "?ANIMAPI: ") .. msg)
    end
end



------------------------------------------
-- Right Arm Items
local rightArm = {}
------------------------------------------
-- addRightItem
-- Add an item to apply an Animation Variable on Equip of the right hand
---- Provide the item's full type. Example: "Base.Item"
---- `animation` can be a string which will simply set the variable to "true", OR
---- `animation` can be a table of variables and their values to set: `{ ["variable"] = value, ["variable2"] = value }`, OR
---- `animation` can be a function. the function provided is given the player and item, and is expected to return a string or a table of variables and their values: `{ ["variable"] = value, ["variable2"] = value }`
---- Checked First!
--- @param item string
--- @param animation string|function
AnimAPI.addRightItem = function(item, animation)
    addType(item, animation, rightArm, "addRightItem")
end

------------------------------------------
-- Right Arm Weapon Types
local rightWeaponType = {}
------------------------------------------
-- addRightWeaponType
-- Add a Weapon Type to apply an Animation Variable on Equip of the right hand
---- `item` should be a `WeaponType`. AnimAPI contains a shortcut for all defined.
---- `animation` can be a string which will simply set the variable to "true", OR
---- `animation` can be a table of variables and their values to set: `{ ["variable"] = value, ["variable2"] = value }`, OR
---- `animation` can be a function. the function provided is given the player and item, and is expected to return a string or a table of variables and their values: `{ ["variable"] = value, ["variable2"] = value }`
---- Checked Second!
--- @param weapontype string
--- @param animation string|function
AnimAPI.addRightWeaponType = function(weapontype, animation)
    addWeaponType(weapontype, animation, rightWeaponType, "addRightWeaponType")
end

------------------------------------------
-- Right Arm Weapon Tag
local rightWeaponTag = {}
------------------------------------------
-- addRightWeaponTag
-- Add a Tag to apply an Animation Variable on Equip of the right hand
---- `item` should be a `Tag` placed on an item.
---- `animation` can be a string which will simply set the variable to "true", OR
---- `animation` can be a table of variables and their values to set: `{ ["variable"] = value, ["variable2"] = value }`, OR
---- `animation` can be a function. the function provided is given the player and item, and is expected to return a string or a table of variables and their values: `{ ["variable"] = value, ["variable2"] = value }`
---- Checked Third!
--- @param tag string
--- @param animation string|function
AnimAPI.addRightWeaponTag = function(tag, animation)
    addTag(tag, animation, rightWeaponTag, "addRightWeaponTag")
end

------------------------------------------
-- Two Handed Items
local twoHanded = {}
------------------------------------------
-- addTwoHandItem
-- Add an item to apply an Animation Variable on Equip of both hands
---- Provide the item's full type. Example: "Base.Item"
---- `animation` can be a string which will simply set the variable to "true", OR
---- `animation` can be a table of variables and their values to set: `{ ["variable"] = value, ["variable2"] = value }`, OR
---- `animation` can be a function. the function provided is given the player and item, and is expected to return a string or a table of variables and their values: `{ ["variable"] = value, ["variable2"] = value }`
---- Checked First!
--- @param item string
--- @param animation string|function
AnimAPI.addTwoHandItem = function(item, animation)
    addType(item, animation, twoHanded, "addTwoHandItem")
end

------------------------------------------
-- Two Hand Weapon Types
local twoHWeaponType = {}
------------------------------------------
-- addTwoHandWeaponType
-- Add a Weapon Type to apply an Animation Variable on Equip of both hands
---- `item` should be a `WeaponType`. AnimAPI contains a shortcut for all defined.
---- `animation` can be a string which will simply set the variable to "true", OR
---- `animation` can be a table of variables and their values to set: `{ ["variable"] = value, ["variable2"] = value }`, OR
---- `animation` can be a function. the function provided is given the player and item, and is expected to return a string or a table of variables and their values: `{ ["variable"] = value, ["variable2"] = value }`
---- Checked Second!
--- @param weapontype string
--- @param animation string|function
AnimAPI.addTwoHandWeaponType = function(weapontype, animation)
    addWeaponType(weapontype, animation, twoHWeaponType, "addTwoHandWeaponType")
end

------------------------------------------
-- Two Hand Weapon Tag
local twoHWeaponTag = {}
------------------------------------------
-- addTwoHandWeaponTag
-- Add a Tag to apply an Animation Variable on Equip of both hands
---- `item` should be a `Tag` placed on an item.
---- `animation` can be a string which will simply set the variable to "true", OR
---- `animation` can be a table of variables and their values to set: `{ ["variable"] = value, ["variable2"] = value }`, OR
---- `animation` can be a function. the function provided is given the player and item, and is expected to return a string or a table of variables and their values: `{ ["variable"] = value, ["variable2"] = value }`
---- Checked Third!
--- @param tag string
--- @param animation string|function
AnimAPI.addTwoHandWeaponTag = function(tag, animation)
    addTag(tag, animation, twoHWeaponTag, "addTwoHandWeaponTag")
end

------------------------------------------
-- Left Arm Items
local leftArm = {}
------------------------------------------
-- addLeftItem
-- Add an item to apply an Animation Variable on Equip of the left hand
---- Provide the item's full type. Example: "Base.Item"
---- `animation` can be a string which will simply set the variable to "true", OR
---- `animation` can be a table of variables and their values to set: `{ ["variable"] = value, ["variable2"] = value }`, OR
---- `animation` can be a function. the function provided is given the player and item, and is expected to return a string or a table of variables and their values: `{ ["variable"] = value, ["variable2"] = value }`
---- Checked First!
AnimAPI.addLeftItem = function(item, animation)
    addType(item, animation, leftArm, "addLeftItem")
end

------------------------------------------
-- Left Arm Weapon Types
local leftWeaponType = {}
------------------------------------------
-- addLeftWeaponType
-- Add a Weapon Type to apply an Animation Variable on Equip of the left hand
---- `item` should be a `WeaponType`. AnimAPI contains a shortcut for all defined.
---- `animation` can be a string which will simply set the variable to "true", OR
---- `animation` can be a table of variables and their values to set: `{ ["variable"] = value, ["variable2"] = value }`, OR
---- `animation` can be a function. the function provided is given the player and item, and is expected to return a string or a table of variables and their values: `{ ["variable"] = value, ["variable2"] = value }`
---- Checked Second!
--- @param weapontype string
--- @param animation string|function
AnimAPI.addLeftWeaponType = function(weapontype, animation)
    addWeaponType(weapontype, animation, leftWeaponType, "addLeftTypeOverride")
end

------------------------------------------
-- Left Weapon Tag
local leftWeaponTag = {}
------------------------------------------
-- addLeftWeaponTag
-- Add a Tag to apply an Animation Variable on Equip of both hands
---- `item` should be a `Tag` placed on an item.
---- `animation` can be a string which will simply set the variable to "true", OR
---- `animation` can be a table of variables and their values to set: `{ ["variable"] = value, ["variable2"] = value }`, OR
---- `animation` can be a function. the function provided is given the player and item, and is expected to return a string or a table of variables and their values: `{ ["variable"] = value, ["variable2"] = value }`
---- Checked Third!
--- @param tag string
--- @param animation string|function
AnimAPI.addLeftWeaponTag = function(tag, animation)
    addTag(tag, animation, leftWeaponTag, "addLeftWeaponTag")
end

------------------------------------------
-- Items
local items = {}
------------------------------------------
-- addItem
-- Add an item to apply an Animation Variable on Equip of either hand
---- Provide the item's full type. Example: "Base.Item"
---- `animation` can be a string which will simply set the variable to "true", OR
---- `animation` can be a table of variables and their values to set: `{ ["variable"] = value, ["variable2"] = value }`, OR
---- `animation` can be a function. the function provided is given the player and item, and is expected to return a string or a table of variables and their values: `{ ["variable"] = value, ["variable2"] = value }`
---- Checked Fourth!
--- @param item string
--- @param animation string|function
AnimAPI.addItem = function(item, animation)
    addType(item, animation, items, "addItem")
end

------------------------------------------
-- Item Weapon Types
local itemWeaponTypes = {}
------------------------------------------
-- addItem
-- Add an item to apply an Animation Variable on Equip of either hand
---- Provide the item's full type. Example: "Base.Item"
---- `animation` can be a string which will simply set the variable to "true", OR
---- `animation` can be a table of variables and their values to set: `{ ["variable"] = value, ["variable2"] = value }`, OR
---- `animation` can be a function. the function provided is given the player and item, and is expected to return a string or a table of variables and their values: `{ ["variable"] = value, ["variable2"] = value }`
---- Checked Fifth!
--- @param weapontype string
--- @param animation string|function
AnimAPI.addItemWeaponType = function(weapontype, animation)
    addWeaponType(weapontype, animation, itemWeaponTypes, "addItemWeaponType")
end

------------------------------------------
-- Item Tag
local itemTag = {}
------------------------------------------
-- addItemTag
-- Add a Tag to apply an Animation Variable on Equip of both hands
---- `item` should be a `Tag` placed on an item.
---- `animation` can be a string which will simply set the variable to "true", OR
---- `animation` can be a table of variables and their values to set: `{ ["variable"] = value, ["variable2"] = value }`, OR
---- `animation` can be a function. the function provided is given the player and item, and is expected to return a string or a table of variables and their values: `{ ["variable"] = value, ["variable2"] = value }`
---- Checked Sixth!
--- @param tag string
--- @param animation string|function
AnimAPI.addItemTag = function(tag, animation)
    addTag(tag, animation, itemTag, "addItemTag")
end

------------------------------------------
--- Functions that do things
--- doClear will clear all current variables from the player
local doClear = function(character, clear, k1, k2, k3)
    for k,_ in pairs(clear) do
        if k and not (k1[k] or k2[k] or k3[k]) then
            character:clearVariable(k)
        end
        clear[k] = nil
    end
end

--- doData is what actually performs the specific actions
--- 
local doData = function(character, test, md, md2)
    if test then
        if type(test) == "table" then -- if a table
            -- expected: `{ ["variable"] = value, ["variable2"] = value }`
            for k,v in pairs(test) do
                character:setVariable(k,v)
                md[k] = v
                if md2 then
                    md2[k] = v
                end
            end
            return true
        elseif type(test) == "string" then
            character:setVariable(test, true)
            md[test] = true
            if md2 then
                md2[test] = true
            end
            return true
        end
    end
    return false
end

------------------------------------------
-- perfoms the action by FullItemType
local doFullType = function(character, item, data, md, md2)

    --Print("doFullType: ", item:getFullType())

    local did = false
    -- is item's full type in our given data
    local st = data[item:getFullType()]
    
    if st then
        local temp
        local tp
        for i=1, #st do
            temp = st[i]
            tp = type(temp)
            did = doData(character, (temp and ((tp == "function" and temp(character, item)) or ((tp == "string" or tp == "table") and temp))), md, md2) or did
        end
    end
  
    return did
end

------------------------------------------
-- perfoms the action by Weapon Type
local doWeaponType = function(character, item, data, md, md2)
    -- handweapons only!
    if not instanceof(item, "HandWeapon") then return false end

    --Print("doWeaponType: ", item:getFullType(), " | WeaponType: ", WeaponType.getWeaponType(item):getType())

    local did = false
    -- is item's WeaponType in our given data
    local st = data[WeaponType.getWeaponType(item)]
    local temp, tp
    if st then
        for i=1, #st do
            temp = st[i]
            tp = type(temp)
            did = doData(character, (temp and ((tp == "function" and temp(character, item)) or ((tp == "string" or tp == "table") and temp))), md, md2) or did
        end
    end
    return did
end

------------------------------------------
-- perfoms the action by Tags
local doTags = function(character, item, data, md, md2)
    --Print("doTags: ", item:getFullType())
    -- Get Tags
    local tags = item:getTags()
    local tag, st, temp, tp
    local did = false
    for i=0, tags:size()-1 do
        tag = tags:get(i)
        st = tag and data[tag]
        --Print("Checking: ", (tag or "nil"))
        if st then
            for j=1, #st do
                temp = st[j]
                tp = type(temp)
                did = doData(character, (temp and ((tp == "function" and temp(character, item)) or ((tp == "string" or tp == "table") and temp))), md, md2) or did
            end
        end
        tag, st, tp, temp = nil, nil, nil, nil
    end
    return did
end

------------------------------------------
-- onEquipPrimary Event
local onEquipPrimary = function(character, item)
    local md = character and AnimAPI.playerData[_getPlayerID(character)]
    if not md then return end

    --Print("onEquipPrimary: ", (AnimAPI.isClient and character:getOnlineID()) or character:getPlayerNum())
    
    doClear(character, md.right, md.left, md.clothes, md.manual)
    md.right = {}

    local found = false
    if instanceof(item, "InventoryItem") then
        -- Check for special Item
        found = doFullType(character, item, rightArm, md.right) or doWeaponType(character, item, rightWeaponType, md.right) or doTags(character, item, rightWeaponTag, md.right) -- By Arm
                or doFullType(character, item, items, md.right) or doWeaponType(character, item, itemWeaponTypes, md.right) or doTags(character, item, itemTag, md.right) -- By General
    end
    AnimAPI.playerData[_getPlayerID(character)] = md
    --return found
end

------------------------------------------
-- onEquipSecondary Event
local onEquipSecondary = function(character, item)
    local md = character and AnimAPI.playerData[_getPlayerID(character)]
    if not md then return end

    --Print("onEquipSecondary: ", (AnimAPI.isClient and character:getOnlineID()) or character:getPlayerNum())

    doClear(character, md.left, md.right, md.clothes, md.manual)
    md.left = {}

    local found = false
    if instanceof(item, "InventoryItem") then
        if character:isItemInBothHands(item) then
            -- clear right
            doClear(character, md.right, md.left, md.clothes, md.manual)
            md.right = {}
            found = doFullType(character, item, twoHanded, md.left, md.right) or doWeaponType(character, item, twoHWeaponType, md.left, md.right) or doTags(character, item, twoHWeaponTag, md.left, md.right)  -- By Arm
                    or doFullType(character, item, items, md.left, md.right) or doWeaponType(character, item, itemWeaponTypes, md.left, md.right) or doTags(character, item, itemTag, md.left, md.right) -- By General
        else
            found = doFullType(character, item, leftArm, md.left) or doWeaponType(character, item, leftWeaponType, md.left)  or doTags(character, item, leftWeaponTag, md.left) -- By Arm
                    or doFullType(character, item, items, md.left) or doWeaponType(character, item, itemWeaponTypes, md.left) or doTags(character, item, itemTag, md.left) -- By General
        end
    end
    AnimAPI.playerData[_getPlayerID(character)] = md
    --return found
end

------------------------------------------
-- on update clothes
local onPlayerUpdateClothes = function(character)
    local md = character and AnimAPI.playerData[_getPlayerID(character)]
    if not md then return end

    --Print("onPlayerUpdateClothes: ", tostring((AnimAPI.isClient and character:getOnlineID()) or character:getPlayerNum()))
    
    doClear(character, md.clothes, md.left, md.right, md.manual)
    md.clothes = {}

    local found = false
	local wears = character:getWornItems()
	for i=0, wears:size()-1 do
		local item = wears:getItemByIndex(i)
		if item then
            --Print("Checking: ", item:getFullType())
			found = doFullType(character, item, items, md.clothes) or doTags(character, item, itemTag, md.clothes)
		end
	end
    AnimAPI.playerData[_getPlayerID(character)] = md

    if AnimAPI.isClient and character:isLocalPlayer()  then
        sendClientCommand("AnimAPI", "Sync", { cmd = "SyncClothes" })
    end
    --return found
end

-- Manual Sync of Animation Data
---- This is a function that can be called to just add unconditional animations.
--- For example, if someone has a Trait that warrants custom animations, they can set that variable here.
AnimAPI.Sync = function(character, animation)
    local md = character and AnimAPI.playerData[_getPlayerID(character)]
    if not md then return end

    if animation then
        if type(animation) == "string" then
            character:setVariable(animation, true)
            md.manual[animation] = true
        elseif type(animation) == "table" then
            for k,v in pairs(animation) do
                character:setVariable(k,v)
                md.manual[k] = v
            end
        end
        if AnimAPI.isClient and character:isLocalPlayer()  then
            sendClientCommand("AnimAPI", "Sync", { cmd = "ManualSync", data = animation })
        end
    end
    AnimAPI.playerData[_getPlayerID(character)] = md
end

------------------------------------------
-- initModData
--- Creates AnimAPI ModData on a player
local initModData = function()
    return {
        manual = {},
        left = {},
        right = {},
        clothes = {}
    }
end

------------------------------------------
-- onCreateLivingCharacter
--- For the online characters
local onCreateLivingCharacter = function(character, desc)
    --Print("onCreateLivingCharacter")
    if instanceof(character, "IsoPlayer") then
        AnimAPI.playerData[_getPlayerID(character)] = initModData()
    end
end

------------------------------------------
-- onCreatePlayer
--- For the local characters
local onCreatePlayer = function(player, character)
    --Print("onCreatePlayer: ", tostring(player))
    AnimAPI.playerData[_getPlayerID(character)] = initModData()
    onEquipPrimary(character, character:getPrimaryHandItem())
    onEquipSecondary(character, character:getSecondaryHandItem())
    onPlayerUpdateClothes(character)

    -- sync the clothes of MP players if the first local player and in MP
    ---- onEquipPrimary and onEquipSecondary are both run already
    if player == 0 and AnimAPI.isClient then
        local players = getOnlinePlayers()
        local p
        for i=0, players:size()-1 do
            p = players:get(i)
            -- send to all other players
            if p and not p:isLocalPlayer() then
                onPlayerUpdateClothes(p)
            end
            p = nil
        end
    end
end

------------------------------------------
-- onLevelPerk
--- When a level up happens
local onLevelPerk = function(character, perk, level, levelUp)
    --Print("onLevelPerk: ", tostring((AnimAPI.isClient and character:getOnlineID()) or character:getPlayerNum()))
    onEquipPrimary(character, character:getPrimaryHandItem())
    onEquipSecondary(character, character:getSecondaryHandItem())
    if AnimAPI.isClient and character:isLocalPlayer()  then
        sendClientCommand("AnimAPI", "Sync", { cmd = "SyncLevelUp" })
    end
end

------------------------------------------
---- Activation function
--- By Default, AnimAPI does nothing until an animation is added to it

local active = false
local ActivateAnimAPIMP = nil
AnimAPI._activateAnimAPI = function()
    if active then return end

    -- Add our events
    Events.OnEquipPrimary.Add(onEquipPrimary)
    Events.OnEquipSecondary.Add(onEquipSecondary)
    Events.OnCreatePlayer.Add(onCreatePlayer)
    Events.LevelPerk.Add(onLevelPerk)
    Events.OnClothingUpdated.Add(onPlayerUpdateClothes)

    if ActivateAnimAPIMP then
        ActivateAnimAPIMP()
    end
    active = true
end

------------------------------------------
-- Add stuff for MP compat
if AnimAPI.isClient then
    -- Cached globals we'll need
    local isLocalPlayer = __classmetatables[IsoPlayer.class].__index.isLocalPlayer
    local _getPlayerByOnlineID = getPlayerByOnlineID

    -- Commands for syncing events
    local Commands = {
        AnimAPI = {}
    }

    Commands.AnimAPI.SyncLevelUp = function(args)
        local player = _getPlayerByOnlineID(args.id)
        if player and not isLocalPlayer(player) then
            onLevelPerk(player)
        end
    end

    Commands.AnimAPI.SyncClothes = function(args)
        local player = _getPlayerByOnlineID(args.id)
        if player and not isLocalPlayer(player) then
            onPlayerUpdateClothes(player)
        end
    end

    Commands.AnimAPI.ManualSync = function(args)
        local player = _getPlayerByOnlineID(args.id)
        if player and not isLocalPlayer(player) then
            AnimAPI.Sync(player, args.data)
        end
    end
    
    local onServerCommand = function(module, command, args)
        if Commands[module] and Commands[module][command] then
            Commands[module][command](args)
        end
    end

    ActivateAnimAPIMP = function()
        Events.OnServerCommand.Add(onServerCommand)
        Events.OnCreateLivingCharacter.Add(onCreateLivingCharacter)
    end
end

return AnimAPI