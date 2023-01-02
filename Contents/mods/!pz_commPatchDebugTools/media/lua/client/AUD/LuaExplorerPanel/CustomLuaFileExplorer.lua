require "ISUI/ISCollapsableWindow"
require("AUD/Init")
AUD.FileExplorer = {}
AUD.FileExplorer.FavFileList = {}

CustomLuaFileExplorerList = ISScrollingListBox:derive("CustomLuaFileExplorerList")


function CustomLuaFileExplorerList:onMouseDoubleClickFile(item)
    if not item then return end
    reloadLuaFile(item)
end

function CustomLuaFileExplorerList:doDrawItem(y, item, alt)
    if y + self:getYScroll() >= self.height then return y + item.height end
    if y + item.height + self:getYScroll() <= 0 then return y + item.height end

    if self.selected == item.index then
        self:drawRect(0, (y), self:getWidth(), self.itemheight-1, 0.3, 0.7, 0.35, 0.15);

    end
    self:drawRectBorder(0, (y), self:getWidth(), self.itemheight, 0.5, self.borderColor.r, self.borderColor.g, self.borderColor.b);
    
    self:drawText(item.text, 15, y + (item.height - self.fontHgt) / 2, 0.9, 0.9, 0.9, 0.9, UIFont.Small);
    y = y + self.itemheight;
    return y;
end

function CustomLuaFileExplorerList:onMouseWheel(del)
    self:setYScroll(self:getYScroll() - (del*self.itemheight*6));
    return true;
end

-----------------

function AUD.FileExplorer.ReadFavFileList()
    local fileTable = {}
	local readFile = getFileReader("AUD_DebugLuaFilesList.txt", true)
	local scanLine = readFile:readLine()
	while scanLine do
		fileTable[#fileTable+1] = scanLine
		scanLine = readFile:readLine()
		if not scanLine then break end
	end
	readFile:close()
	return fileTable
end

function AUD.FileExplorer.WriteFavFileList()
    local writeFile = getFileWriter("AUD_DebugLuaFilesList.txt", true, false)
	for i = 1, #AUD.FileExplorer.FavFileList do
		writeFile:write(AUD.FileExplorer.FavFileList[i].."\r\n");
	end
	writeFile:close()
end


AUD.FileExplorer.FavFileList = AUD.FileExplorer.ReadFavFileList()

