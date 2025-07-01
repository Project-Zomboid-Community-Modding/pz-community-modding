require "ISUI/ISCollapsableWindow"
require "InitToolBar"

AUD.TeleportPointExplorer = {}
AUD.TeleportPointExplorer.FavFileList = {}


TeleportPointList = ISScrollingListBox:derive("TeleportPointList")


function TeleportPointList:onMouseDoubleClickFile(item)
    if not item then return end
    local pl = getPlayer()
    pl:setX(item[1])
    pl:setY(item[2])
    pl:setLx(item[1])
    pl:setLy(item[2])
    pl:setZ(item[3])
end


function TeleportPointList:doDrawItem(y, item, alt)
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

function TeleportPointList:onMouseWheel(del)
    self:setYScroll(self:getYScroll() - (del*self.itemheight*6));
    return true;
end
