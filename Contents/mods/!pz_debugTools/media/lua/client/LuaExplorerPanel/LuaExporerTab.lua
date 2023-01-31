require "InitToolBar"

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)

AUDLuaExplorerTab = ISPanelJoypad:derive("AUDLuaExplorerTab")

function AUDLuaExplorerTab:initialise(category)
    ISPanelJoypad.initialise(self);

    self.fileCategory = category

    self:instantiate()
    self:setAnchorRight(true)
    self:setAnchorLeft(true)
    self:setAnchorTop(true)
    self:setAnchorBottom(true)
    self:noBackground()
    self:setScrollChildren(true)
    self:addScrollBars()

    self.borderColor = {r=0, g=0, b=0, a=0};

    local th = 0--self:titleBarHeight()
    local rh = 0--self:resizeWidgetHeight()
    local entryHgt = FONT_HGT_SMALL + 2 * 2

    self.fileList = CustomLuaFileExplorerList:new(0, th + entryHgt, self.width, self.height - th - rh - entryHgt*2 - 4);
    self.fileList.anchorRight = true;
    self.fileList.anchorBottom = true;
    self.fileList:initialise();
    self.fileList:setOnMouseDoubleClick(self, CustomLuaFileExplorerList.onMouseDoubleClickFile);
    self.fileList:setFont(UIFont.Small, 3)
    self:addChild(self.fileList);

    self.textEntry = ISTextEntryBox:new("", 0, th, self.width, entryHgt);
    self.textEntry:initialise();
    self.textEntry:instantiate();
    self.textEntry:setClearButton(true)
    self.textEntry:setText("");

    if self.fileCategory == "FAV" then
        self.textEntry.onTextChange = function() 
            AUD.luaFileExplorer:activateView("All")
            AUD.LuaExplorer.allTab.textEntry:focus()
            AUD.LuaExplorer.allTab.textEntry:setText(AUD.LuaExplorer.favTab.textEntry:getInternalText())
            AUD.LuaExplorer.favTab.textEntry:setText("")
            AUD.LuaExplorer.favTab.textEntry:unfocus()
        end
    end

    self:addChild(self.textEntry);
    self.lastText = self.textEntry:getInternalText();

   


    self:fill();

    local button
    if self.fileCategory == "ALL" then
        button = ISButton:new(0, 0, 50, self.fileList.itemheight, "+", self, self.onButtonAdd)
    else
        button = ISButton:new(0, 0, 50, self.fileList.itemheight, "-", self, self.onButtonRemove)
    end

    button:initialise()
    self.fileList:addChild(button)
    self.fileList.doRepaintStencil = true
    button:setVisible(false)
    self.buttonSelect = button

    if self.fileCategory == "FAV" then
        local reloadFunc = function(ss)
            for i=1, #(ss.items) do
                reloadLuaFile(ss.items[i].item)
            end
        end

        button = ISButton:new(self.width - 63, 1, 50, self.fileList.itemheight - 3, "Reload All", self.fileList, reloadFunc)
        button:initialise()
        self:addChild(button)
    end
end



function AUDLuaExplorerTab:fill()
    self.fileList:clear();

    if self.fileCategory == "FAV" then
        for i=1, #AUD.FileExplorer.FavFileList do 
            local path = AUD.FileExplorer.FavFileList[i]
            local name = getShortenedFilename(path)
            self.fileList:addItem(name, path)
        end
    else
        local c = getLoadedLuaCount();

        for i = 0, c-1 do
            local path = getLoadedLua(i);
            local name = getShortenedFilename(path);
            if string.trim(self.textEntry:getInternalText()) == nil or string.contains(string.lower(name), string.lower(string.trim(self.textEntry:getInternalText()))) then
                self.fileList:addItem(name, path);
            end
        end
    end
end

function AUDLuaExplorerTab:onMouseDoubleClickFile(item)
    if not item then return end
    reloadLuaFile(item)
end


function AUDLuaExplorerTab:update()
    local text = string.trim(self.textEntry:getInternalText());

    if text ~= self.lastText then
       self:fill();
       self.lastText = text;
    end

    self:updateReloadButton();
end

function AUDLuaExplorerTab:doDrawItem(y, item, alt)
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



function AUDLuaExplorerTab:updateReloadButton()
    local x,y = self.fileList:getMouseX(), self.fileList:getMouseY()
    local row = self.fileList:isMouseOver() and self.fileList:rowAt(x, y) or -1
    if row == self.buttonSelectRow then return end
    if row == -1 then
        self.buttonSelect:setVisible(false)
    else
        self.buttonSelect:setVisible(true)
        self.buttonSelect:setX(self.width - self.buttonSelect.width - 15)
        local itemY = self.fileList:topOfItem(row)
        self.buttonSelect:setY(itemY + self.fileList:getYScroll())
    end
    self.buttonSelectRow = row
end

function AUDLuaExplorerTab:onButtonAdd()
    if self.buttonSelectRow == -1 then return end
    local item = self.fileList.items[self.buttonSelectRow]
    if not item then return end

    table.insert(AUD.FileExplorer.FavFileList, item.item)
    AUD.FileExplorer.WriteFavFileList()

    AUD.LuaExplorer.favTab:fill()
end

function AUDLuaExplorerTab:onButtonRemove()
    if self.buttonSelectRow == -1 then return end
    local item = self.fileList.items[self.buttonSelectRow]
    if not item then return end

    for i=1, #AUD.FileExplorer.FavFileList do
        if AUD.FileExplorer.FavFileList[i] == item.item then
            table.remove(AUD.FileExplorer.FavFileList, i)
            break
        end
    end
    AUD.FileExplorer.WriteFavFileList()
    self:fill()
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












