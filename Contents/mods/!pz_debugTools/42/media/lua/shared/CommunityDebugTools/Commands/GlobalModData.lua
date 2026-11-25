local debug = require "!!!communityPatchDebugTools - shared"
local Inspect = require "CommunityDebugTools/Commands/Inspect"

local GlobalModData = {}
GlobalModData.onNames = nil
GlobalModData.onTable = nil

function GlobalModData.getNames()
	local names = {}
	local tableNames = ModData.getTableNames()
	for i = 0, tableNames:size() - 1 do
		table.insert(names, tableNames:get(i))
	end
	table.sort(names, function(a, b) return string.lower(a) < string.lower(b) end)
	return names
end

function GlobalModData.requestNames()
	if not isClient() then return end
	sendClientCommand("ceDebug","GlobalModData.names",{})
end

function GlobalModData.requestTable(name)
	if not isClient() then return end
	sendClientCommand("ceDebug","GlobalModData.get",{name = name})
end

debug.serverCommands["GlobalModData.names"] = function(player,args)
	sendServerCommand(player,"ceDebug","GlobalModData.names",{names = GlobalModData.getNames()})
end

debug.serverCommands["GlobalModData.get"] = function(player,args)
	local name = args and args.name
	local data = name and ModData.get(name)
	local result = {name = name, found = data ~= nil}
	if data then result.lines = Inspect.getTableLines(data, " -> ") end
	sendServerCommand(player,"ceDebug","GlobalModData.get",result)
end

debug.clientCommands["GlobalModData.names"] = function(args)
	if GlobalModData.onNames then GlobalModData.onNames(args) end
end

debug.clientCommands["GlobalModData.get"] = function(args)
	if GlobalModData.onTable then GlobalModData.onTable(args) end
end

debug.GlobalModData = GlobalModData
return GlobalModData
