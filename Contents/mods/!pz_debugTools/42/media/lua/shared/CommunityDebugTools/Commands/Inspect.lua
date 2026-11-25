local debug = require "!!!communityPatchDebugTools - shared"

local Inspect = {}
Inspect.maxLines = 1000
Inspect.maxDepth = 10
Inspect.serverData = {}
Inspect.onServerData = nil

function Inspect.getLocator(obj)
	if not obj then return nil end
	local locator
	if instanceof(obj, "InventoryItem") then
		locator = {kind = "item", id = obj:getID()}
	elseif instanceof(obj, "BaseVehicle") then
		locator = {kind = "vehicle", id = obj:getId()}
	elseif instanceof(obj, "IsoPlayer") then
		locator = {kind = "player", id = obj:getOnlineID()}
	elseif instanceof(obj, "IsoZombie") then
		locator = {kind = "zombie", id = obj:getOnlineID()}
	elseif instanceof(obj, "IsoDeadBody") then
		local square = obj:getSquare()
		if not square then return nil end
		local bodies = square:getDeadBodys()
		for i = 0, bodies:size() - 1 do
			if bodies:get(i) == obj then
				locator = {kind = "body", x = square:getX(), y = square:getY(), z = square:getZ(), index = i}
				break
			end
		end
	elseif instanceof(obj, "IsoObject") then
		local square = obj:getSquare()
		if not square or obj:getObjectIndex() < 0 then return nil end
		locator = {kind = "object", x = square:getX(), y = square:getY(), z = square:getZ(), index = obj:getObjectIndex(), sprite = obj:getSprite() and obj:getSprite():getName()}
	end
	if not locator then return nil end
	locator.key = locator.kind .. ":" .. tostring(locator.id or (locator.x .. "," .. locator.y .. "," .. locator.z .. ":" .. locator.index))
	return locator
end

function Inspect.resolve(player, locator)
	local kind = locator.kind
	if kind == "item" then
		return player and player:getInventory():getItemWithIDRecursiv(locator.id)
	elseif kind == "vehicle" then
		return getVehicleById(locator.id)
	elseif kind == "player" then
		return getPlayerByOnlineID(locator.id)
	elseif kind == "zombie" then
		local zombies = getCell():getZombieList()
		for i = 0, zombies:size() - 1 do
			local zombie = zombies:get(i)
			if zombie:getOnlineID() == locator.id then return zombie end
		end
	else
		local square = getCell():getGridSquare(locator.x, locator.y, locator.z)
		if not square then return nil end
		if kind == "body" then
			local bodies = square:getDeadBodys()
			if locator.index < bodies:size() then return bodies:get(locator.index) end
		elseif kind == "object" then
			local objects = square:getObjects()
			local obj = locator.index < objects:size() and objects:get(locator.index)
			local spriteName = obj and obj:getSprite() and obj:getSprite():getName()
			if obj and spriteName == locator.sprite then return obj end
			for i = 0, objects:size() - 1 do
				obj = objects:get(i)
				if obj:getSprite() and obj:getSprite():getName() == locator.sprite then return obj end
			end
		end
	end
	return nil
end

function Inspect.getTableLines(data, separator)
	local lines = {}
	separator = separator or "  =  "

	local function parse(t, indent, depth)
		for k,v in pairs(t) do
			if #lines >= Inspect.maxLines then return end
			if type(v) == "table" and depth < Inspect.maxDepth then
				table.insert(lines, indent .. "[" .. tostring(k) .. "]" .. separator)
				parse(v, indent .. "    ", depth + 1)
			else
				table.insert(lines, indent .. "[" .. tostring(k) .. "]" .. separator .. tostring(v))
			end
		end
	end
	parse(data, "", 0)
	return lines
end

function Inspect.getModDataLines(obj)
	local modData = obj and obj.getModData and obj:getModData()
	if not modData then return {} end
	return Inspect.getTableLines(modData)
end

function Inspect.getFieldLines(obj)
	local lines = {}
	if not obj then return lines end
	for i = 0, getNumClassFields(obj) - 1 do
		if #lines >= Inspect.maxLines then break end
		local javaField = getClassField(obj, i)
		if javaField then
			local valueAsText = tostring(javaField:get(obj))
			local simpleClass = valueAsText:match('[^.]+$')
			if simpleClass and simpleClass ~= valueAsText and string.sub(valueAsText, 1, 1) ~= "[" then valueAsText = simpleClass end
			table.insert(lines, javaField:getName() .. "  =  " .. valueAsText)
		end
	end
	return lines
end

function Inspect.requestServerData(obj)
	if not isClient() then return nil end
	local locator = Inspect.getLocator(obj)
	if not locator then return nil end
	Inspect.serverData[locator.key] = nil
	sendClientCommand("ceDebug","Inspect.get",locator)
	return locator.key
end

debug.serverCommands["Inspect.get"] = function(player,args)
	local obj = Inspect.resolve(player, args)
	local result = {key = args.key, found = obj ~= nil}
	if obj then
		result.className = getClassSimpleName(obj)
		result.modData = Inspect.getModDataLines(obj)
		result.fields = Inspect.getFieldLines(obj)
	end
	sendServerCommand(player,"ceDebug","Inspect.data",result)
end

debug.clientCommands["Inspect.data"] = function(args)
	Inspect.serverData[args.key] = args
	if Inspect.onServerData then Inspect.onServerData(args) end
end

debug.Inspect = Inspect
return Inspect
