local debug = require "!!!communityPatchDebugTools - shared"

local Tiles = {}

function Tiles.destroy(object)
	local square = object and object:getSquare()
	if not square then return end
	if isClient() then
		local sprite = object:getSprite()
		sendClientCommand("ceDebug","Tiles.destroy",{x=square:getX(),y=square:getY(),z=square:getZ(),index=object:getObjectIndex(),sprite=sprite and sprite:getName()})
		return
	end
	square:transmitRemoveItemFromSquare(object)
end
debug.serverCommands["Tiles.destroy"] = function(player,args)
	local square = getCell():getGridSquare(args.x,args.y,args.z)
	if not square then return end
	local objects = square:getObjects()
	if args.index < 0 or args.index >= objects:size() then return end
	local object = objects:get(args.index)
	local sprite = object:getSprite()
	if args.sprite and (not sprite or sprite:getName() ~= args.sprite) then return end
	Tiles.destroy(object)
end
debug.serverCommandCapabilities["Tiles.destroy"] = "UseBrushToolManager"

debug.Tiles = Tiles
return Tiles
