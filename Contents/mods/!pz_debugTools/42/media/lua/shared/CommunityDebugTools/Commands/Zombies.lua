local debug = require "!!!communityPatchDebugTools - shared"

local Zombies = {}

function Zombies.killAll()
	if isClient() then sendClientCommand("ceDebug","Zombies.killAll",{}) return end
	local objects = getCell():getObjectListForLua()
	for i = objects:size() - 1, 0, -1 do
		local zombie = objects:get(i)
		if instanceof(zombie, "IsoZombie") and not zombie:isDead() then
			zombie:die()
		end
	end
end
debug.serverCommands["Zombies.killAll"] = function(player,args) Zombies.killAll() end
debug.serverCommandCapabilities["Zombies.killAll"] = "ManipulateZombie"

debug.Zombies = Zombies
return Zombies
