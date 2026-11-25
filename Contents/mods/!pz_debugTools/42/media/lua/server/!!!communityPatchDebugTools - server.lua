local debug = require "!!!communityPatchDebugTools - shared"


if isClient() then

else
	function debug.hasCapability(player, command)
		if not isServer() then return true end
		if not player then return false end
		local capability = Capability[debug.serverCommandCapabilities[command] or "UseDebugContextMenu"]
		return capability ~= nil and player:getRole():hasCapability(capability)
	end

	function debug.OnClientCommand(module, command, player, args)
		if module == "ceDebug" then
			local f = debug.serverCommands[command]
			if type(f) == "function" then
				if not debug.hasCapability(player, command) then
					print("Debug: ",player and player:getUsername()," lacks capability for command ",command)
					return
				end
				return f(player,args)
			else
				print("Debug: received invalid command ",command)
			end
		end
	end
	Events.OnClientCommand.Add(debug.OnClientCommand)
end
