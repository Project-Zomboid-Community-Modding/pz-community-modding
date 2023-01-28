require "InitToolBar"

AUD.TeleportTable = {}

AUDTeleport = ISTabPanel:derive("AUDTeleport")

function AUDTeleport:RestoreLayout(name, layout)
    ISLayoutManager.DefaultRestoreWindow(self, layout)
end

function AUDTeleport:SaveLayout(name, layout)
    ISLayoutManager.DefaultSaveWindow(self, layout)
    ISLayoutManager.SaveWindowVisible(self, layout)
end

function AUDTeleport:initialise()
    ISTabPanel.initialise(self);

    self:setAnchorBottom(true);
    self:setAnchorRight(true);
    self.target = self;
    self:setEqualTabWidth(true)
    self:setCenterTabs(true)
    AUD.teleportWindow = self:wrapInCollapsableWindow("Teleport");
    
    local closeFunc = function(obj)
        ISCollapsableWindow.close(obj);
        AUD.teleportWindow:setRemoved(true)
        AUD.TeleportPanel.toolbarButton:setImage(AUD.TeleportPanel.texture_Off)
    end
    
    AUD.teleportWindow.close = closeFunc
    AUD.teleportWindow.closeButton.onmousedown = closeFunc
    AUD.teleportWindow:setResizable(true);

    -- All tab
    AUD.TeleportTable.All = AUDTeleportTab:new(0, 48, AUD.teleportWindow:getWidth(), AUD.teleportWindow:getHeight() - AUD.teleportWindow.nested.tabHeight)
    AUD.TeleportTable.All:initialise("All")
    AUD.teleportWindow.nested:addView("All", AUD.TeleportTable.All)

    self:loadPoints()

    AUD.teleportWindow:addToUIManager();
    AUD.TeleportPanel.toolbarButton:setImage(AUD.TeleportPanel.texture_On)

    ISLayoutManager.RegisterWindow('AUDTeleport', AUDTeleport, self)
end


function AUDTeleport:savePoints()
    local writeFile = getFileWriter("AUDTeleportPoints.txt", true, false)
    for category, tab in pairs(AUD.TeleportTable) do
        writeFile:write("CATEGORY" .. "\r\n");
        writeFile:write(category .. "\r\n");
        for i=1, #tab.fileList.items do
            local item = tab.fileList.items[i]

            writeFile:write(item.text .. "\r\n");
            writeFile:write(item.item[1] .. "\r\n");
            writeFile:write(item.item[2] .. "\r\n");
            writeFile:write(item.item[3] .. "\r\n");
        end
    end
    writeFile:close()
end

function AUDTeleport:loadPoints()
	local readFile = getFileReader("AUDTeleportPoints.txt", true)
    local scanLine = readFile:readLine()
    
    local currentTab = nil

    while scanLine do
        if scanLine == "CATEGORY" then
            local cat = readFile:readLine()            
            if cat ~= "All" then
                AUD.TeleportTable[cat] = AUDTeleportTab:new(0, 48, AUD.teleportWindow:getWidth(), AUD.teleportWindow:getHeight() - AUD.teleportWindow.nested.tabHeight)
                AUD.TeleportTable[cat]:initialise(cat)
                AUD.teleportWindow.nested:addView(cat, AUD.TeleportTable[cat])   
            end
            currentTab = AUD.TeleportTable[cat]
        else
            local name = scanLine
            local x = tonumber(readFile:readLine())
            local y = tonumber(readFile:readLine())
            local z = tonumber(readFile:readLine())
            currentTab.fileList:addItem(name, {x, y, z})
        end
		scanLine = readFile:readLine()
		if not scanLine then break end
	end
	readFile:close()
	return fileTable
end

