local debug = {}
debug.clientCommands = {}
debug.serverCommands = {}
debug.serverCommandCapabilities = {}

function debug.OnServerCommand(module, command, args)
	if module == "ceDebug" then
		local f = debug.clientCommands[command]
		if type(f) == "function" then
			return f(args)
		else
			print("Debug: received invalid server command ",command)
		end
	end
end

if isClient() then
	Events.OnServerCommand.Add(debug.OnServerCommand)
end

return debug
