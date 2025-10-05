local AUD = require "InitToolBar"
local CustomLuaFileExplorerList = require "LuaExplorerPanel/CustomLuaFileExplorer"

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)

---@class AUDLuaExplorerTab : ISPanelJoypad
---@field fileCategory string
---@field fileList CustomLuaFileExplorerList
local AUDLuaExplorerTab = ISPanelJoypad:derive("AUDLuaExplorerTab")

function AUDLuaExplorerTab:initialise(category)
    ISPanelJoypad.initialise(self)

    self.fileCategory = category

    self:instantiate()
    self:setAnchorRight(true)
    self:setAnchorLeft(true)
    self:setAnchorTop(true)
    self:setAnchorBottom(true)
    self:noBackground()
    self:setScrollChildren(true)
    self:addScrollBars()

    self.borderColor = {r=0, g=0, b=0, a=0}

    local th = 0--self:titleBarHeight()
    local rh = 0--self:resizeWidgetHeight()
    local entryHgt = FONT_HGT_SMALL + 2 * 2

    self.fileList = CustomLuaFileExplorerList:new(0, th + entryHgt, self.width, self.height - th - rh - entryHgt*2 - 4)
    self.fileList.anchorRight = true
    self.fileList.anchorBottom = true
    self.fileList:initialise()
    if self.fileCategory == "MOD" then
        -- reload a mod folder on double click
        self.fileList:setOnMouseDoubleClick(self, self.onButtonMod)
    else
        -- reload a mod file on double click
        self.fileList:setOnMouseDoubleClick(self, self.onMouseDoubleClickFile)
    end
    self.fileList:setFont(UIFont.Small, 3)
    self:addChild(self.fileList)

    self.textEntry = ISTextEntryBox:new("", 0, th, self.width, entryHgt)
    self.textEntry:initialise()
    self.textEntry:instantiate()
    self.textEntry:setClearButton(true)
    self.textEntry:setText("")

    if self.fileCategory ~= "ALL" then
        self.textEntry.onTextChange = function() 
            AUD.luaFileExplorer:activateView("All")
            AUD.LuaExplorer.allTab.textEntry:focus()
            AUD.LuaExplorer.allTab.textEntry:setText(AUD.LuaExplorer.favTab.textEntry:getInternalText())
            AUD.LuaExplorer.favTab.textEntry:setText("")
            AUD.LuaExplorer.favTab.textEntry:unfocus()
            AUD.LuaExplorer.modTab.textEntry:setText("")
            AUD.LuaExplorer.modTab.textEntry:unfocus()
        end
    end

    self:addChild(self.textEntry)
    self.lastText = self.textEntry:getInternalText()

   


    self:fill()

    local button
    if self.fileCategory == "ALL" then
        button = ISButton:new(0, 0, 50, self.fileList.itemheight, "+", self, self.onButtonAdd)
    elseif self.fileCategory == "FAV" then
        button = ISButton:new(0, 0, 50, self.fileList.itemheight, "-", self, self.onButtonRemove)
    elseif self.fileCategory == "MOD" then
        button = ISButton:new(0, 0, 50, self.fileList.itemheight, "Reload", self, self.onButtonMod)
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
    self.fileList:clear()
    local c = getLoadedLuaCount()

    if self.fileCategory == "FAV" then
        for i=1, #AUD.FileExplorer.FavFileList do 
            local path = AUD.FileExplorer.FavFileList[i]
            local name = getShortenedFilename(path)
            self.fileList:addItem(name, path)
        end
    elseif self.fileCategory == "MOD" then


        function getModName(path) --Return the name of the mod folder
            local segments = {}
            for segment in string.gmatch(path, "[^/]+") do
                table.insert(segments, segment)
            end
            
            for i, segment in ipairs(segments) do
                if segment == "mods" then
                    return segments[i + 1]
                end
            end
            return
        end

        local modList = {}
        for i = 0, c - 1 do
            local path = getLoadedLua(i)
            local name = getModName(path)
            if name ~= nil then -- name is nil if the file is from the base game. Preventing reload of base all at once.
                if modList[name] == nil then
                    modList[name] = {name = name, paths = path}
                else
                    modList[name].paths = modList[name].paths .. "|" .. path
                end
            end
        end
        table.sort(modList, function(a, b) return a.name < b.name end) --Sort by mod name
        for k,v in pairs(modList) do
            if modList[k].paths == nil then return end
            if modList[k].name == nil then return end
            -- name = mod folder name, paths = all files in the mod folder as a string separated by "|" e.g. "path1|path2|path3"
            self.fileList:addItem(modList[k].name, modList[k].paths)
        end
    else -- ALL
        for i = 0, c-1 do
            local path = getLoadedLua(i)
            local name = getShortenedFilename(path)
            if string.trim(self.textEntry:getInternalText()) == nil or string.contains(string.lower(name), string.lower(string.trim(self.textEntry:getInternalText()))) then
                self.fileList:addItem(name, path)
            end
        end
    end
end

---User double clicks a file entry in the list
---@param item string
function AUDLuaExplorerTab:onMouseDoubleClickFile(item)
    if not item then return end
    reloadLuaFile(item)
end


function AUDLuaExplorerTab:update()
    local text = string.trim(self.textEntry:getInternalText())

    if text ~= self.lastText then
       self:fill()
       self.lastText = text
    end

    self:updateReloadButton()
end

function AUDLuaExplorerTab:doDrawItem(y, item, alt)
    if y + self:getYScroll() >= self.height then return y + item.height end
    if y + item.height + self:getYScroll() <= 0 then return y + item.height end

    if self.selected == item.index then
        self:drawRect(0, (y), self:getWidth(), self.itemheight-1, 0.3, 0.7, 0.35, 0.15)

    end
    self:drawRectBorder(0, (y), self:getWidth(), self.itemheight, 0.5, self.borderColor.r, self.borderColor.g, self.borderColor.b)
    
    self:drawText(item.text, 15, y + (item.height - self.fontHgt) / 2, 0.9, 0.9, 0.9, 0.9, UIFont.Small)
    y = y + self.itemheight
    return y
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

-- Reload all files in the mod folder
function AUDLuaExplorerTab:onButtonMod()
    if self.buttonSelectRow == -1 then return end
    local item = self.fileList.items[self.buttonSelectRow]
    if not item then return end
    local paths = {}

    -- Split the string into a table of strings using a string delimiter
    function splitString(inputString, delimiter)
        local result = {}
        for match in (inputString .. delimiter):gmatch("(.-)" .. delimiter) do
            table.insert(result, match)
        end
        return result
    end
    --return all a mod folder's files as a table of strings. e.g. {"path1", "path2", "path3"}
    paths = splitString(item.item, "|")
    for i = 1, #paths do
        --reload each file
        reloadLuaFile(paths[i])
    end
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
		writeFile:write(AUD.FileExplorer.FavFileList[i].."\r\n")
	end
	writeFile:close()
end

AUD.FileExplorer.FavFileList = AUD.FileExplorer.ReadFavFileList()

return AUDLuaExplorerTab