local debug = require "!!!communityPatchDebugTools - shared"

local LuaFiles = {}
LuaFiles.maxResults = 300
LuaFiles.onServerList = nil
LuaFiles.onServerReloaded = nil

function LuaFiles.normalize(path)
	local normalized = string.gsub(path, "\\", "/")
	return normalized
end

function LuaFiles.getModName(path)
	local modName
	local previous
	for segment in string.gmatch(LuaFiles.normalize(path), "[^/]+") do
		if segment == "media" then break end
		if previous == "mods" then modName = segment end
		previous = segment
	end
	return modName
end

function LuaFiles.getRelativePath(path)
	return string.match(LuaFiles.normalize(path), "(media/lua/.+)$")
end

function LuaFiles.getSide(path)
	return string.match(LuaFiles.normalize(path), "media/lua/(%a+)/")
end

function LuaFiles.getKey(mod, relative)
	return (mod or "") .. ":" .. (relative or "")
end

function LuaFiles.getLoaded()
	local files = {}
	for i = 0, getLoadedLuaCount() - 1 do
		local path = getLoadedLua(i)
		table.insert(files, {path = path, name = getShortenedFilename(path), mod = LuaFiles.getModName(path), relative = LuaFiles.getRelativePath(path)})
	end
	return files
end

function LuaFiles.getMods()
	local counts = {}
	local mods = {}
	for _,file in ipairs(LuaFiles.getLoaded()) do
		if file.mod then
			if not counts[file.mod] then
				counts[file.mod] = {name = file.mod, count = 0, paths = {}}
				table.insert(mods, counts[file.mod])
			end
			counts[file.mod].count = counts[file.mod].count + 1
			table.insert(counts[file.mod].paths, file.path)
		end
	end
	table.sort(mods, function(a, b) return string.lower(a.name) < string.lower(b.name) end)
	return mods
end

function LuaFiles.matches(text, filter)
	if not filter or filter == "" then return true end
	return string.find(string.lower(text), string.lower(filter), 1, true) ~= nil
end

function LuaFiles.reloadFiles(paths)
	local serverEntries = {}
	for _,path in ipairs(paths) do
		reloadLuaFile(path)
		local side = LuaFiles.getSide(path)
		if isClient() and (side == "shared" or side == "server") then
			table.insert(serverEntries, {mod = LuaFiles.getModName(path), relative = LuaFiles.getRelativePath(path)})
		end
	end
	if #serverEntries > 0 then LuaFiles.reloadOnServer(serverEntries) end
	return #paths, #serverEntries
end

function LuaFiles.requestServerList(filter)
	if not isClient() then return end
	sendClientCommand("ceDebug","LuaFiles.list",{filter = filter or ""})
end

function LuaFiles.reloadOnServer(entries)
	if not isClient() then return end
	sendClientCommand("ceDebug","LuaFiles.reload",{entries = entries})
end

debug.serverCommands["LuaFiles.list"] = function(player,args)
	local filter = args and args.filter or ""
	local result = {filter = filter, files = {}, mods = {}, total = 0}
	if filter == "" then
		for _,mod in ipairs(LuaFiles.getMods()) do
			table.insert(result.mods, {name = mod.name, count = mod.count})
		end
	else
		for _,file in ipairs(LuaFiles.getLoaded()) do
			if LuaFiles.matches(file.name, filter) then
				result.total = result.total + 1
				if #result.files < LuaFiles.maxResults then
					table.insert(result.files, {path = file.path, name = file.name, mod = file.mod})
				end
			end
		end
	end
	sendServerCommand(player,"ceDebug","LuaFiles.list",result)
end
debug.serverCommandCapabilities["LuaFiles.list"] = "ReloadLuaFiles"

debug.serverCommands["LuaFiles.reload"] = function(player,args)
	local byPath, byKey, byMod = {}, {}, {}
	for _,file in ipairs(LuaFiles.getLoaded()) do
		byPath[file.path] = file.path
		if file.relative then byKey[LuaFiles.getKey(file.mod, file.relative)] = file.path end
		if file.mod then
			byMod[file.mod] = byMod[file.mod] or {}
			table.insert(byMod[file.mod], file.path)
		end
	end

	local toReload = {}
	local missing = 0
	for _,entry in pairs(args and args.entries or {}) do
		local found
		if entry.path then
			found = byPath[entry.path]
			if found then table.insert(toReload, found) end
		elseif entry.modAll then
			found = byMod[entry.modAll]
			if found then for _,path in ipairs(found) do table.insert(toReload, path) end end
		else
			found = byKey[LuaFiles.getKey(entry.mod, entry.relative)]
			if found then table.insert(toReload, found) end
		end
		if not found then missing = missing + 1 end
	end

	for _,path in ipairs(toReload) do reloadLuaFile(path) end
	print("Debug: ",player and player:getUsername() or "server"," reloaded ",#toReload," server Lua files")
	sendServerCommand(player,"ceDebug","LuaFiles.reloaded",{count = #toReload, missing = missing})
end
debug.serverCommandCapabilities["LuaFiles.reload"] = "ReloadLuaFiles"

debug.clientCommands["LuaFiles.list"] = function(args)
	if LuaFiles.onServerList then LuaFiles.onServerList(args) end
end

debug.clientCommands["LuaFiles.reloaded"] = function(args)
	print("Debug: server reloaded ",args.count," Lua files (",args.missing," not found)")
	if LuaFiles.onServerReloaded then LuaFiles.onServerReloaded(args) end
end

debug.LuaFiles = LuaFiles
return LuaFiles
