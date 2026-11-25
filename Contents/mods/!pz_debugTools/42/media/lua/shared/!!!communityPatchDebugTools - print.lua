if _G.printWithModTag then return end

local modTags = {}
local selfFile

local function getModTag(fileDir)
	local cached = modTags[fileDir]
	if cached then return cached end
	local normalized = string.gsub(fileDir, "\\", "/")
	local modInfoDir = normalized:match("^(.-/mods/[^/]+/)")
	local modInfo = modInfoDir and getModInfo(modInfoDir)
	local modID = modInfo and modInfo:getId()
	local tag = modID and ("[" .. modID .. "] ") or ""
	modTags[fileDir] = tag
	return tag
end

local function getCallerTag()
	local coroutine = getCurrentCoroutine()
	if not coroutine then return "" end
	for i = getCallframeTop(coroutine) - 1, 0, -1 do
		local luaCallFrame = getCoroutineCallframeStack(coroutine, i)
		local fileDir = luaCallFrame and getFilenameOfCallframe(luaCallFrame)
		if fileDir and fileDir ~= "" and fileDir ~= selfFile then
			return getModTag(fileDir)
		end
	end
	return ""
end

function _G.printWithModTag(...)
	local output = getCallerTag()
	for i = 1, select('#', ...) do
		output = output .. "    " .. tostring(select(i, ...))
	end
	DebugLog.log(output)
end

selfFile = getFilenameOfClosure(_G.printWithModTag)
_G.print = _G.printWithModTag
