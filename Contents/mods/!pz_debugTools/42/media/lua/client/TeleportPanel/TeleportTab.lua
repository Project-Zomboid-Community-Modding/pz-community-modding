local AUD = require "InitToolBar"

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)

AUDTeleportTab = ISPanelJoypad:derive("AUDTeleportTab")

function AUDTeleportTab:initialise(category)
    ISPanelJoypad.initialise(self);

    self.pointCategory = category

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

    self.fileList = TeleportPointList:new(0, th + entryHgt, self.width, self.height - th - rh - entryHgt*2 - 4);
    self.fileList.anchorRight = true;
    self.fileList.anchorBottom = true;
    self.fileList:initialise();
    self.fileList:setOnMouseDoubleClick(self, TeleportPointList.onMouseDoubleClickFile);
    self.fileList:setFont(UIFont.Small, 3)
    self:addChild(self.fileList);

    local button = ISButton:new(0, 0, 50, self.fileList.itemheight, "Remove", self, self.onButtonRemove)
    button:initialise()
    self.fileList:addChild(button)
    self.fileList.doRepaintStencil = true
    button:setVisible(false)
    self.buttonSelect = button

    ---
    local func = function()
        local modal = AddPointPanel:new(Core:getInstance():getScreenWidth()/2 - 125, Core:getInstance():getScreenHeight()/2 - 150 , 250, 300, nil, nil)
        modal:initialise();
        modal:addToUIManager();
    end

    button = ISButton:new(1, 1, 50, self.fileList.itemheight - 3, "Add point", nil, func)
    button:initialise()
    self:addChild(button)
end


function AUDTeleportTab:update()
    self:updateReloadButton();
end

function AUDTeleportTab:doDrawItem(y, item, alt)
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



function AUDTeleportTab:updateReloadButton()
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

function AUDTeleportTab:onButtonRemove()
    if self.buttonSelectRow == -1 then return end
    local item = self.fileList.items[self.buttonSelectRow]
    if not item then return end

    self.fileList:removeItemByIndex(self.buttonSelectRow)

    
    for i=1, #AUD.TeleportTable["All"].fileList.items do
        local item2 = AUD.TeleportTable["All"].fileList.items[i]

        if item.text == item2.text and 
                item.item[1] == item2.item[1] and
                item.item[2] == item2.item[2] and
                item.item[3] == item2.item[3] then
            AUD.TeleportTable["All"].fileList:removeItemByIndex(i)
            break
        end
    end

    if #self.fileList.items == 0 then
        AUD.TeleportTable[self.pointCategory] = nil
    end

    AUD.teleport:savePoints()    

    AUD.teleportWindow:close()
    AUD.teleport = AUDTeleport:new(100, 100, 400, 250)
    AUD.teleport:initialise()
end









