require "ISUI/ISCollapsableWindow"
local AUD = require "CommunityDebugTools/debugToolbar"
local HoverButtonList = require "CommunityDebugTools/HoverButtonList"

AUD.FileExplorer = {}
AUD.FileExplorer.FavFileList = {}
AUD.FileExplorer.ModList = {}

---@class CustomLuaFileExplorerList : HoverButtonList
local CustomLuaFileExplorerList = HoverButtonList:derive("CustomLuaFileExplorerList")

-----------------

function AUD.FileExplorer.ReadFavFileList()
	local fileTable = {}
	local readFile = getFileReader("AUD_DebugLuaFilesList.txt", true)
	local scanLine = readFile:readLine()
	while scanLine do
		if scanLine ~= "" then fileTable[#fileTable+1] = scanLine end
		scanLine = readFile:readLine()
	end
	readFile:close()
	return fileTable
end

function AUD.FileExplorer.WriteFavFileList()
	local writeFile = getFileWriter("AUD_DebugLuaFilesList.txt", true, false)
	for i = 1, #AUD.FileExplorer.FavFileList do
		writeFile:write(AUD.FileExplorer.FavFileList[i].."\r\n")
	end
	writeFile:close()
end

function AUD.FileExplorer.IndexOfFav(path)
	for i = 1, #AUD.FileExplorer.FavFileList do
		if AUD.FileExplorer.FavFileList[i] == path then return i end
	end
end

function AUD.FileExplorer.AddFav(path)
	if AUD.FileExplorer.IndexOfFav(path) then return end
	table.insert(AUD.FileExplorer.FavFileList, path)
	AUD.FileExplorer.WriteFavFileList()
end

function AUD.FileExplorer.RemoveFav(path)
	local index = AUD.FileExplorer.IndexOfFav(path)
	if not index then return end
	table.remove(AUD.FileExplorer.FavFileList, index)
	AUD.FileExplorer.WriteFavFileList()
end

function AUD.FileExplorer.MoveFav(path, offset)
	local index = AUD.FileExplorer.IndexOfFav(path)
	local list = AUD.FileExplorer.FavFileList
	if not index or not list[index + offset] then return end
	list[index], list[index + offset] = list[index + offset], list[index]
	AUD.FileExplorer.WriteFavFileList()
end

AUD.FileExplorer.FavFileList = AUD.FileExplorer.ReadFavFileList()

return CustomLuaFileExplorerList
