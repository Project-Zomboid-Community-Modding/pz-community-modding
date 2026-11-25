local debug = require "!!!communityPatchDebugTools - shared"

local Bodies = {}
Bodies.radius = 45

---@param player IsoPlayer|IsoGameCharacter|IsoMovingObject|IsoObject
function Bodies.getAll(player)
	local bodies = {}
	local cell = getCell()
	local radius = Bodies.radius
	local pX, pY, pZ = math.floor(player:getX()), math.floor(player:getY()), math.floor(player:getZ())

	for x = pX - radius, pX + radius do
		for y = pY - radius, pY + radius do
			local square = cell:getGridSquare(x, y, pZ)
			local bodiesOnSq = square and square:getDeadBodys()
			if bodiesOnSq then
				for i = 0, bodiesOnSq:size()-1 do
					table.insert(bodies, bodiesOnSq:get(i))
				end
			end
		end
	end

	return bodies
end


function Bodies.removeAll(player)
	if isClient() then sendClientCommand("ceDebug","Bodies.removeAll",{}) return end
	for _,body in ipairs(Bodies.getAll(player)) do
		body:getSquare():removeCorpse(body, false)
	end
end
debug.serverCommands["Bodies.removeAll"] = function(player,args) Bodies.removeAll(player) end


function Bodies.reanimateAll(player)
	if isClient() then sendClientCommand("ceDebug","Bodies.reanimateAll",{}) return end
	for _,body in ipairs(Bodies.getAll(player)) do
		body:reanimateNow()
	end
end
debug.serverCommands["Bodies.reanimateAll"] = function(player,args) Bodies.reanimateAll(player) end


function Bodies.moveAllTo(player, square)
	if not square then return end
	if isClient() then sendClientCommand("ceDebug","Bodies.moveAllTo",{x = square:getX(), y = square:getY(), z = square:getZ()}) return end

	for _,body in ipairs(Bodies.getAll(player)) do
		local bodySq = body:getSquare()
		if bodySq ~= square then
			local bodyItem = body:getItem()
			bodySq:removeCorpse(body, false)
			local dropX, dropY = ZombRandFloat(0.1, 0.9), ZombRandFloat(0.1, 0.9)
			local dropZ = square:getApparentZ(dropX, dropY) - square:getZ()
			square:AddWorldInventoryItem(bodyItem, dropX, dropY, dropZ)
		end
	end
end
debug.serverCommands["Bodies.moveAllTo"] = function(player,args)
	if not (player and args and args.x and args.y and args.z) then return end
	Bodies.moveAllTo(player, getCell():getGridSquare(args.x, args.y, args.z))
end


debug.Bodies = Bodies
return Bodies
